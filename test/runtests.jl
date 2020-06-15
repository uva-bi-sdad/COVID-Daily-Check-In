using DailyCheckIn, Test, Documenter

@testset "Documentation" begin
    using Documenter, DailyCheckIn

    DocMeta.setdocmeta!(DailyCheckIn,
                       :DocTestSetup,
                       :(using DailyCheckIn;
                         givenname = "José Bayoán";
                         surname = "Santiago Calderón";
                         division = "SDAD";
                         health = "good";
                         email = "jbs3hp@virginia.edu";
                         wd = RemoteWebDriver(
                             Capabilities("chrome"),
                             host = get(ENV, "WEBDRIVER_HOST", "localhost"),
                             port = parse(Int, get(ENV, "WEBDRIVER_PORT", "4444")),
                             path = ""
                             );
                         session = DailyCheckIn.WebDriver.Session(wd);
                         ENV["COLUMNS"] = 120; ENV["LINES"] = 30;),
                       recursive = true)
    # doctest(DailyCheckIn, fix = true)
    makedocs(sitename = "DailyCheckIn",
             modules = [DailyCheckIn],
             pages = [
                 "Home" => "index.md",
                 "API" => "api.md",
                ],
             source = joinpath("..", "docs", "src"),
             build = joinpath("..", "docs", "build"),
            #  source = joinpath("docs", "src"),
            #  build = joinpath("docs", "build"),
             )
    @test true
end
