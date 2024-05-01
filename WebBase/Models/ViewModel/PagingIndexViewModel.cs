using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebHome.Models.ViewModel
{
    public class PagingIndexViewModel
    {
        public PagingIndexViewModel()
        {
            PagingSize = 5;
            PageSize = 5;
        }

        [Required]
        [Display(Name = "CurrentIndex")]
        public int CurrentIndex { get; set; }

        [Required]
        [Display(Name = "PageSize")]
        public int PageSize { get; set; }

        [Required]
        [Display(Name = "PagingSize")]
        public int PagingSize { get; set; }

    }
}