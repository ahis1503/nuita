document.addEventListener('turbolinks:load', function(){
  let paginateContainer = document.getElementById('willPaginateContainer');
  let pageNumber = 1;

  if(paginateContainer){
    const getCsrfToken = () => {
      const metaCollection = document.getElementsByTagName('meta');
      const metas = Array.from(metaCollection);

      for(let meta of metas){
        if(meta.getAttribute('name') === 'csrf-token') {
          console.log(meta.getAttribute('content'));
          return meta.getAttribute('content');
        }
      }
      return '';
    }

    const fetchOptions:RequestInit = {
      method: 'GET',
      mode: 'same-origin',
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': getCsrfToken()
      }
    }

    const observerOptions = {
      root: null,
      rootMargin: '240px',
      threshold: [1.0]
    };

    const observer = new IntersectionObserver((entries) => {
      for(const e of entries){
        let more_posts_url:string = location.pathname + '?page=' + ++pageNumber;
        console.log(more_posts_url);
        if(more_posts_url){
          fetch(more_posts_url, fetchOptions).then((response) => {
            return response.text();
          }).then((partial:string) => {
            let timelineContainer = document.querySelector('.nweets-list');
            timelineContainer.insertAdjacentHTML('beforeend', partial);
          });
        }
      }
    }, observerOptions);

    observer.observe(document.querySelector('#willPaginateContainer'));
  }
});
