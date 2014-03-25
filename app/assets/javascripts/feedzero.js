window.FeedZero = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    FeedZero.calendars = new FeedZero.Collections.Calendars();
    FeedZero.entries = new FeedZero.Collections.Events();
    FeedZero.calendars.fetch({
      success:  function () {
        new FeedZero.Routers.AppRouter({
              $rootEl: $("#content"),
              calendars: FeedZero.calendars,
              entries: FeedZero.entries
            });
            Backbone.history.start();
          }

      })
    }


    
}

$(document).ready(function(){
  FeedZero.initialize();
});
