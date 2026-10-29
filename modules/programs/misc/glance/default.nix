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
      theme = {
        background-color = "240 21 15";
        contrast-multiplier = 1.2;
        primary-color = "217 92 83";
        positive-color = "115 54 76";
        negative-color = "347 70 65";
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
                  title = "Hacker News";
                  feeds = [
                    {url = "https://hnrss.org/frontpage";}
                  ];
                }
                {
                  type = "reddit";
                  subreddit = "NixOS";
                  style = "horizontal-cards";
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "XMR-USD";
                      name = "Monero";
                    }
                  ];
                }
                {
                  type = "releases";
                  show-source-icon = true;
                  repositories = [
                    "gitlab:fdroid/fdroidclient"
                    "dockerhub:gotify/server"
                    "NixOS/nixpkgs"
                    "caelestia-dots/shell"
                    "openai/codex"
                    "anthropics/claude-code"
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
