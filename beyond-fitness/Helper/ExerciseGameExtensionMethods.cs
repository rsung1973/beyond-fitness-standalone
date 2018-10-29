using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Web;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class ExerciseGameExtensionMethods
    {

        public static void CheckExerciseGameRank(this ExerciseGameResult resultItem)
        {
            ThreadPool.QueueUserWorkItem(t =>
            {
                try
                {
                    using (var models = new ModelSource<UserProfile>())
                    {
                        var table = models.GetTable<ExerciseGameRank>();
                        var item = table.Where(r => r.UID == resultItem.UID && r.ExerciseID == resultItem.ExerciseID).FirstOrDefault();
                        if (item == null)
                        {
                            item = new ExerciseGameRank
                            {
                                UID = resultItem.UID,
                                ExerciseID = resultItem.ExerciseID,
                            };
                            table.InsertOnSubmit(item);
                        }

                        if (!item.RecordID.HasValue || item.ExerciseGameResult.TestDate < DateTime.Today.AddMonths(-3) || item.ExerciseGameResult.Score < resultItem.Score)
                        {
                            item.RecordID = resultItem.TestID;
                            models.SubmitChanges();

                            resultItem.ExerciseID.UpdateExerciseGameRank();
                        }
                    }
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });
        }

        public static void UpdateExerciseGameRank(this int exerciseID)
        {
            ThreadPool.QueueUserWorkItem(t =>
            {
                try
                {
                    using (var models = new ModelSource<UserProfile>())
                    {
                        models.RefreshExerciseGameRank(exerciseID);
                        models.RefreshPersonalRank();
                    }
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });
        }

        public static void RefreshExerciseGameRank<TEntity>(this ModelSource<TEntity> models, int exerciseID)
            where TEntity : class, new()
        {
            var exerciseItem = models.GetTable<ExerciseGameItem>().Where(r => r.ExerciseID == exerciseID).First();

            var table = models.GetTable<ExerciseGameRank>();
            models.ExecuteCommand(@"
                                UPDATE ExerciseGameRank
                                SET        RankingScore = NULL, Rank = NULL
                                WHERE   (ExerciseID = {0})", exerciseID);

            models.ExecuteCommand(@"
                                UPDATE ExerciseGameRank
                                SET        RecordID = NULL
                                FROM     ExerciseGameRank INNER JOIN
                                               ExerciseGameResult ON ExerciseGameRank.RecordID = ExerciseGameResult.TestID
                                WHERE   (ExerciseGameRank.ExerciseID = {0}) AND (ExerciseGameResult.TestDate < {1})",
                exerciseID, DateTime.Today.AddMonths(-3));

            IOrderedQueryable<IGrouping<decimal, ExerciseGameRank>> items;

            if (exerciseItem.Descending == false)
            {
                items = table
                .Join(models.GetTable<ExerciseGameContestant>().Where(c => c.Status == (int)Naming.GeneralStatus.Successful),
                    r => r.UID, c => c.UID, (r, c) => r)
                .Where(r => r.ExerciseID == exerciseID && r.RecordID.HasValue)
                .OrderBy(r => r.ExerciseGameResult.Score) //.Take(10)
                .GroupBy(r => r.ExerciseGameResult.Score)
                .OrderBy(g => g.Key);
            }
            else
            {
                items = table
                .Join(models.GetTable<ExerciseGameContestant>().Where(c => c.Status == (int)Naming.GeneralStatus.Successful),
                    r => r.UID, c => c.UID, (r, c) => r)
                .Where(r => r.ExerciseID == exerciseID && r.RecordID.HasValue)
                .OrderByDescending(r => r.ExerciseGameResult.Score) //.Take(10)
                .GroupBy(r => r.ExerciseGameResult.Score)
                .OrderByDescending(g => g.Key);
            }

            //int score = Math.Min(10, models.GetTable<ExerciseGameContestant>().Where(c => c.Status == (int)Naming.GeneralStatus.Successful).Count());
            int score = models.GetTable<ExerciseGameContestant>().Where(c => c.Status == (int)Naming.GeneralStatus.Successful).Count();
            int range, rankIndex = 1;
            foreach (var g in items)
            {
                range = 0;
                foreach (var rank in g)
                {
                    rank.RankingScore = score;
                    rank.Rank = rankIndex;
                    range++;
                }
                score -= range;
                rankIndex++;
            }
            models.SubmitChanges();
        }

        public static void RefreshPersonalRank<TEntity>(this ModelSource<TEntity> models) 
            where TEntity : class, new()
        {
            int rankIndex;
            models.ExecuteCommand("DELETE FROM ExerciseGamePersonalRank");
            rankIndex = 1;
            var personalRank = models.GetTable<ExerciseGamePersonalRank>();
            foreach (var p in models.GetTable<ExerciseGameRank>()
                .Where(r => r.RankingScore.HasValue)
                .GroupBy(r => r.UID).Select(g => new { UID = g.Key, TotalScore = g.Sum(p => p.RankingScore) })
                .GroupBy(s => s.TotalScore)
                .OrderByDescending(s => s.Key))
            {
                foreach (var rank in p)
                {
                    var item = models.GetTable<ExerciseGameContestant>().Where(c => c.UID == rank.UID).First();
                    item.TotalScope = p.Key;
                    item.Rank = rankIndex;
                    item.ExerciseGamePersonalRank = new ExerciseGamePersonalRank
                    {
                        TotalScope = p.Key.Value,
                        Rank = rankIndex
                    };

                    //personalRank.InsertOnSubmit(new ExerciseGamePersonalRank
                    //{
                    //    UID = rank.UID,
                    //    TotalScope = p.Key.Value,
                    //    Rank = rankIndex
                    //});
                }
                rankIndex++;
            }

            models.SubmitChanges();
        }

        public static void UpdateExerciseGameContestant(this ExerciseGameContestant contestant)
        {
            if (contestant == null)
                return;

            ThreadPool.QueueUserWorkItem(t =>
            {
                try
                {
                    using (var models = new ModelSource<UserProfile>())
                    {
                        if (contestant.Status == (int)Naming.GeneralStatus.Failed)
                        {
                            models.ExecuteCommand(@"UPDATE ExerciseGameRank
                                    SET        RankingScore = NULL, Rank = NULL
                                    WHERE   (UID = {0})", contestant.UID);
                        }

                        foreach(var item in models.GetTable<ExerciseGameItem>())
                        {
                            models.RefreshExerciseGameRank(item.ExerciseID);
                        }

                        models.RefreshPersonalRank();

                    }
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });
        }

        public static void RefreshExerciseGameRank()
        {
            ThreadPool.QueueUserWorkItem(t =>
            {
                try
                {
                    using (var models = new ModelSource<UserProfile>())
                    {
                        foreach (var item in models.GetTable<ExerciseGameItem>())
                        {
                            models.RefreshExerciseGameRank(item.ExerciseID);
                        }

                        models.RefreshPersonalRank();

                    }
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });
        }

        public static void RefreshExerciseGameContestant<TEntity>(this ModelSource<TEntity> models, ExerciseGameContestant contestant)
            where TEntity : class, new()
        {
            try
            {
                if (contestant != null && contestant.Status == (int)Naming.GeneralStatus.Failed)
                {
                    models.ExecuteCommand(@"UPDATE ExerciseGameRank
                                    SET        RankingScore = NULL, Rank = NULL
                                    WHERE   (UID = {0})", contestant.UID);
                }

                foreach (var item in models.GetTable<ExerciseGameItem>())
                {
                    models.RefreshExerciseGameRank(item.ExerciseID);
                }

                models.RefreshPersonalRank();


            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
