var galleryFilterOptions = {};
var filterizr = new Filterizr('.gallery-filter', galleryFilterOptions);

var galleryFilterControls = document.querySelectorAll('.gallery-filter-controls li');
var galleryFilterActive = document.querySelectorAll('.gallery-filter-active');

galleryFilterControls.forEach(el => el.addEventListener('click',e =>{
    for(let i=0; i < galleryFilterControls.length; i++){galleryFilterControls[i].classList.remove('color-highlight');}
    el.classList.add('color-highlight');
}));