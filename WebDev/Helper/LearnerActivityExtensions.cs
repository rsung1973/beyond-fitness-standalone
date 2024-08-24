using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.DataAccess;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

namespace WebHome.Helper
{
    public static class LearnerActivityExtensions
    {
        public static BonusTransaction AwardLessonMissionBonus(this LessonFeedBack item, GenericManager<BFDataContext> models, CampaignMission.CampaignMissionType missionID, LessonMissionBonus.BonusBonusType? status = null)
        {
            var awardingItem = models.GetTable<LessonMissionBonusAwardingItem>()
                .Where(b => b.MissionID == (int)missionID)
                .Where(b => b.PriceID == item.RegisterLesson.ClassLevel).FirstOrDefault();

            if (awardingItem == null)
            {
                return null;
            }

            //var bonusItem = models.GetTable<LessonMissionBonus>()
            //    .Where(b => b.ItemID == awardingItem.ItemID)
            //    .Where(b => b.LessonID == item.LessonID)
            //    .Where(b => b.RegisterID == item.RegisterID)
            //    .FirstOrDefault();

            //if (bonusItem != null)
            //{
            //    return bonusItem.CampaignMissionBonus.BonusTransaction.FirstOrDefault();
            //}

            var account = item.RegisterLesson.UID.PromptDepositAccount(models);
            if (account == null)
            {
                return null;
            }

            var txnItem = new BonusTransaction
            {
                UID = account.UID,
                TransactionDate = DateTime.Now,
                TransactionPoint = status == LessonMissionBonus.BonusBonusType.Rollback ? -awardingItem.PointValue : awardingItem.PointValue,
                Reason = $"完成{awardingItem.CampaignMission.Mission}",
                CampaignMissionBonus = new CampaignMissionBonus
                {
                    CompleteDate = DateTime.Now,
                    LessonMissionBonus = new LessonMissionBonus
                    {
                        ItemID = awardingItem.ItemID,
                        LessonID = item.LessonID,
                        RegisterID = item.RegisterID,
                        BonusStatus = (int?)status,
                    },
                },
            };

            models.GetTable<BonusTransaction>().InsertOnSubmit(txnItem);
            models.SubmitChanges();

            account.CommitBonusSettlement(models);
            return txnItem;
        }

        public static void RollbackLessonMissionBonus(this LessonTime item, GenericManager<BFDataContext> models, CampaignMission.CampaignMissionType missionID)
        {
            foreach(var feedback in item.LessonFeedBack)
            {
                feedback.AwardLessonMissionBonus(models, missionID, LessonMissionBonus.BonusBonusType.Rollback);
            }
        }


        public static BonusDepositAccount PromptDepositAccount(this int uid, GenericManager<BFDataContext> models)
        {
            var learner = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();

            if (learner == null)
            {
                return null;
            }

            var account = learner.BonusDepositAccount;
            if (account == null)
            {
                account = learner.BonusDepositAccount = new BonusDepositAccount
                {
                    UID = learner.UID,
                    DepositPoint = 0,
                };

                models.SubmitChanges();
            }

            return account;
        }

        public static BonusDepositAccount CommitBonusSettlement(this BonusDepositAccount account, GenericManager<BFDataContext> models,bool? rebuild = false)
        {
            if (account == null)
            {
                return null;
            }

            var settlement = account.BonusDepositSettlement;
            if (settlement == null)
            {
                settlement = new BonusDepositSettlement
                {
                    TransactionID = -1,
                    UID = account.UID,
                };
            }

            settlement.SettlementDate = DateTime.Now;

            if (rebuild == true)
            {
                settlement.TransactionID = -1;
                account.DepositPoint = 0;
            }

            var items = models.GetTable<BonusTransaction>()
                            .Where(t => t.UID == account.UID)
                            .Where(t => t.TransactionID > settlement.TransactionID);

            if (items.Any())
            {
                account.BonusDepositSettlement ??= settlement;

                var subtotal = items.Sum(t => t.TransactionPoint);
                account.DepositPoint += subtotal;
                settlement.TransactionID = items.OrderByDescending(t => t.TransactionID)
                    .First().TransactionID;
            }
            else if (settlement.TransactionID < 0)
            {
                account.DepositPoint = 0;
            }

            models.SubmitChanges();

            return account;
        }
    }
}