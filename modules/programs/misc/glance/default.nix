{
  # Glance dashboard, served locally at http://127.0.0.1:8080 on boot
  services.glance = {
    enable = true;
    openFirewall = false; # localhost only
    settings = {
      server = {
        host = "127.0.0.1";
        port = 8080;
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {type = "calendar";}
                {
                  type = "weather";
                  location = "Chicago, United States"; # change me
                  units = "imperial";
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "rss";
                  title = "News";
                  feeds = [
                    {url = "https://hnrss.org/frontpage";}
                  ];
                }
                {
                  type = "reddit";
                  subreddit = "NixOS";
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "monitor";
                  title = "Services";
                  sites = [];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
