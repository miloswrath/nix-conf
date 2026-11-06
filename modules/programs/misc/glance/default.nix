# Glance dashboard: http://127.0.0.1:8280
# Runs as a native hardened systemd service (no container). Glance only fetches widget
# data on page load when a cache entry has expired, so idle CPU is ~0; the limits below
# keep the Go runtime small and stop it from competing with foreground work.
# Verify: `systemctl status glance` and `systemd-cgtop -1 | grep glance`.
{...}: let
  googleNews = query: "https://news.google.com/rss/search?q=${query}&hl=en-US&gl=US&ceid=US:en";
  bookmark = title: url: {inherit title url;};
in {
  services.glance = {
    enable = true;
    openFirewall = false;
    settings = {
      server = {
        host = "127.0.0.1";
        port = 8280;
      };

      # Catppuccin Mocha (HSL): base bg, mauve accent to match gtk catppuccin-mocha-mauve, green/red
      theme = {
        background-color = "240 21 15";
        contrast-multiplier = 1.2;
        primary-color = "267 84 81";
        positive-color = "115 54 76";
        negative-color = "343 81 75";
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "clock";
                  hour-format = "12h";
                }
                {
                  type = "calendar";
                  first-day-of-week = "sunday";
                }
                {
                  type = "weather";
                  location = "Chicago, Illinois, United States";
                  units = "imperial";
                  hour-format = "12h";
                }
                {
                  type = "markets";
                  cache = "30m";
                  markets = [
                    {
                      symbol = "XMR-USD";
                      name = "Monero";
                    }
                    {
                      symbol = "^GSPC";
                      name = "S&P 500";
                    }
                    {
                      symbol = "SNX";
                      name = "TD SYNNEX";
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "https://search.brave.com/search?q={QUERY}";
                  autofocus = true;
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "AI";
                      links = [
                        (bookmark "Claude" "https://claude.ai")
                        (bookmark "ChatGPT" "https://chatgpt.com")
                        (bookmark "Anthropic Console" "https://console.anthropic.com")
                        (bookmark "OpenAI Platform" "https://platform.openai.com")
                        (bookmark "Hugging Face" "https://huggingface.co")
                        (bookmark "OpenRouter" "https://openrouter.ai")
                      ];
                    }
                    {
                      title = "Dev / Nix";
                      links = [
                        (bookmark "GitHub" "https://github.com")
                        (bookmark "GitLab" "https://gitlab.com")
                        (bookmark "MyNixOS" "https://mynixos.com")
                        (bookmark "NixOS Discourse" "https://discourse.nixos.org")
                        (bookmark "Figma" "https://www.figma.com")
                      ];
                    }
                    {
                      title = "UIowa";
                      links = [
                        (bookmark "MyUI" "https://myui.uiowa.edu")
                        (bookmark "Outlook" "https://outlook.office.com")
                        (bookmark "REDCap" "https://redcap.icts.uiowa.edu")
                        (bookmark "Time & HR" "https://time.hr.uiowa.edu")
                      ];
                    }
                    {
                      title = "Daily";
                      links = [
                        (bookmark "Gmail" "https://mail.google.com")
                        (bookmark "YouTube" "https://www.youtube.com")
                        (bookmark "instagram" "https://instagram.com")
                      ];
                    }
                  ];
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "rss";
                      title = "AI";
                      cache = "3h";
                      limit = 20;
                      collapse-after = 6;
                      feeds = [
                        {url = "https://simonwillison.net/atom/everything/";}
                        {url = "https://openai.com/news/rss.xml";}
                        {url = "https://huggingface.co/blog/feed.xml";}
                        {url = "https://www.latent.space/feed";}
                        {url = "https://news.smol.ai/rss.xml";}
                      ];
                    }
                    {
                      type = "rss";
                      title = "Linux / Nix";
                      cache = "3h";
                      limit = 20;
                      collapse-after = 6;
                      feeds = [
                        {url = "https://discourse.nixos.org/c/announcements/8.rss";}
                        {url = "https://weekly.nixos.org/feeds/all.rss.xml";}
                        {url = "https://www.phoronix.com/rss.php";}
                        {url = "https://lwn.net/headlines/rss";}
                      ];
                    }
                    {
                      type = "rss";
                      title = "Tech";
                      cache = "2h";
                      limit = 20;
                      collapse-after = 6;
                      feeds = [
                        {url = "https://lobste.rs/rss";}
                        {url = "https://feeds.arstechnica.com/arstechnica/index";}
                        {url = "https://www.theverge.com/rss/index.xml";}
                      ];
                    }
                    {
                      type = "rss";
                      title = "Distribution";
                      cache = "3h";
                      limit = 20;
                      collapse-after = 6;
                      feeds = [
                        {
                          url = googleNews "%22TD+SYNNEX%22+OR+%22Ingram+Micro%22+OR+%22Arrow+Electronics%22+OR+Avnet+OR+%22Exclusive+Networks%22+when:7d";
                          title = "Distributors";
                        }
                        {url = "https://www.crn.com/news/channel-programs/rss.xml";}
                        {url = "https://www.channele2e.com/feed";}
                      ];
                    }
                    {
                      type = "rss";
                      title = "Palantir / FDE";
                      cache = "3h";
                      limit = 20;
                      collapse-after = 6;
                      feeds = [
                        {url = "https://blog.palantir.com/feed";}
                        {
                          url = googleNews "Palantir+when:7d";
                          title = "Palantir news";
                        }
                        {
                          url = googleNews "%22forward+deployed+engineer%22+OR+%22forward-deployed+engineering%22";
                          title = "FDE";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "hacker-news";
                  limit = 15;
                  collapse-after = 5;
                  cache = "1h";
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "releases";
                  cache = "6h";
                  show-source-icon = true;
                  collapse-after = 6;
                  repositories = [
                    "hyprwm/Hyprland"
                    "caelestia-dots/shell"
                    "caelestia-dots/cli"
                    "Gerg-L/spicetify-nix"
                    "anthropics/claude-code"
                    "openai/codex"
                    "kovidgoyal/kitty"
                    "sxyazi/yazi"
                    "glanceapp/glance"
                  ];
                }
                # These repos don't publish GitHub releases, so track commits instead
                {
                  type = "rss";
                  title = "Upstream commits";
                  cache = "6h";
                  limit = 10;
                  collapse-after = 4;
                  feeds = [
                    {
                      url = "https://github.com/miloswrath/nix-conf";
                      title = "nix-conf";

                    }
                    {
                      url = "https://github.com/miloswrath/nixvim-but-worse/commits/master.atom";
                      title = "nixvim-but-worse";
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  systemd.services.glance = {
    # Keep the Go runtime to one OS thread and trigger GC early so RSS stays small
    environment = {
      GOMAXPROCS = "1";
      GOMEMLIMIT = "40MiB";
      GOGC = "50";
    };
    serviceConfig = {
      MemoryHigh = "64M"; # start reclaiming here (measured peak ~45M while parsing feeds)
      MemoryMax = "96M"; # hard ceiling
      MemorySwapMax = "0";
      CPUQuota = "25%";
      CPUWeight = 20;
      IOWeight = 20;
      Nice = 10;
      CPUSchedulingPolicy = "batch";
      IOSchedulingClass = "idle";
      TasksMax = 64;
    };
  };
}
