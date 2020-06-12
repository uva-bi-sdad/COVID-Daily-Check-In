module DailyCheckIn

using WebDriver
using WebDriver: Session
using Dates: Date, DateFormat, Dates.format, today

export checkin, Capabilities, RemoteWebDriver, Date

"""
    DATEFORMAT::DateFormat

Date format used by the form.
"""
const DATEFORMAT = DateFormat("mm/dd/yyyy")
"""
    URL::String

URL of the form.
"""
const URL = "https://app.smartsheet.com/b/form/d4ff720727c74ed0bfa80bf5541babee"
"""
    checkin(wd::RemoteWebDriver,
            givenname::AbstractString,
            surname::AbstractString,
            division::AbstractString,
            health::AbstractString;
            date::Date = today(),
            working::Bool = true,
            essential::Bool = false,
            leave::Union{Bool, AbstractString} = false,
            email::Bool = true,
            test::Bool = false)

Check in for the day.

```jldoctest
julia> checkin(wd, givenname, surname, division, health, test = true)

```
"""
function checkin(wd::RemoteWebDriver,
                 givenname::AbstractString,
                 surname::AbstractString,
                 division::AbstractString,
                 health::AbstractString;
                 date::Date = today(),
                 working::Bool = true,
                 essential::Bool = false,
                 leave::Union{Bool, AbstractString} = false,
                 email::Bool = true,
                 test::Bool = false)
    # date = today()
    # working = true
    # essential = false
    # leave = false
    # email = true
    # test = false
    session = Session(wd)
    navigate!(session, URL)
    @assert current_url(session) == URL
    givenname!(session, givenname)
    surname!(session, surname)
    division!(session, division)
    health!(session, health)
    date!(session, date)
    working!(session, working)
    essential!(session, essential)
    leave!(session, leave)
    if email
        element = Element(session, "xpath", """//*[@name="EMAIL_RECEIPT_CHECKBOX"]""")
        click!(element)
        @assert parse(Bool, element_attr(element, "value"))
    end
    submit = Element(session, "xpath", """//*[@data-client-id="form_submit_btn"]""")
    if !test
        click!(submit)
    end
    delete!(session)
    nothing
end
"""
    surname!(session::Session, name::AbstractString)::Nothing

Fill out the surname.

```jldoctest
julia> DailyCheckIn.surname!(session, "Smith")

```
"""
function surname!(session::Session, surname::AbstractString)
    element = Element(session, "css selector", "#text_box_Last\\ Name")
    script!(session, "arguments[0].value = arguments[1];", element, "")
    element_keys!(element, surname)
    @assert element_attr(element, "value") == surname
    nothing
end
"""
    givenname!(session::Session, name::AbstractString)::Nothing

Fill out the given name.

```jldoctest
julia> DailyCheckIn.givenname!(session, "John")

```
"""
function givenname!(session::Session, givenname::AbstractString)
    element = Element(session, "css selector", "#text_box_First\\ Name")
    script!(session, "arguments[0].value = arguments[1];", element, "")
    element_keys!(element, givenname)
    @assert element_attr(element, "value") == givenname
    nothing
end
"""
    date!(session::Session, date::Date = today())::Nothing

Fill out the date.

```jldoctest
julia> DailyCheckIn.date!(session)

```
"""
function date!(session::Session, date::Date = today())
    date = format(today(), DATEFORMAT)
    element = Element(session, "xpath", """//*[@id="date_Date"]""")
    script!(session, "arguments[0].value = arguments[1];", element, date)
    @assert element_attr(element, "value") == date
    nothing
end
"""
    division!(session::Session, division::AbstractString)::Nothing

Fill out the division. Valid options include "ADMIN", "EXEC ADMIN", "SDAD", "NSSAC", and "MATH".

```jldoctest
julia> DailyCheckIn.division!(session::Session, "SDAD")

```
"""
function division!(session::Session, division::AbstractString)
    element = Element(session, "css selector", "#NwGybyG > div")
    options = Elements(element, "css selector", "#NwGybyG > div > div > label > input")
    choices = element_attr.(options, "title")
    idx = findfirst(isequal(division), choices)
    if isnothing(idx)
        throw(ArgumentError("division must be one of $(join(("\"$choice\"" for choice in choices), ", "))."))
    end
    choice = options[idx]
    click!(choice)
    @assert parse(Bool, element_attr(choice, "checked"))
    nothing
end
"""
    DailyCheckInworking!(session::Session, working::Bool = true)::Nothing

Are you working remotely? 

```jldoctest
julia> DailyCheckIn.working!(session)

julia> DailyCheckIn.working!(session, false)

```
"""
function working!(session::Session, working::Bool = true)
    open_options = Element(session, "css selector", "#eG1lvl8 > div > div")
    click!(open_options)
    menu = Element(session, "xpath", """//div[@class="css-11unzgr react-select__menu-list"]""")
    options = Elements(menu, "xpath", """*""")
    choices = element_text.(options)
    choice = options[findfirst(isequal(working ? "Yes" : "No"), choices)]
    click!(choice)
    @assert element_text(open_options) == (working ? "Yes" : "No")
    nothing
end
"""
    essential!(session::Session, essential::Bool = false)

Are you an essential employee on the Admin Team working onsite today?

```jldoctest
julia> DailyCheckIn.essential!(session)

julia> DailyCheckIn.essential!(session, true)

```
"""
function essential!(session::Session, essential::Bool = false)
    open_options = Element(session, "xpath", """//*[@id="MkRPlP2"]/div/div/div[1]""")
    click!(open_options)
    options = Elements(session, "xpath", """//div[@class="css-1tcdovw-menu react-select__menu"]/div/div""")
    choices = element_text.(options)
    idx = findfirst(isequal(essential ? "Yes" : "No"), choices)
    choice = options[idx]
    click!(choice)
    recorded_choice = Element(session, "xpath", """//*[@id="MkRPlP2"]/div/div[1]""")
    @assert element_text(recorded_choice) == (essential ? "Yes" : "No")
    nothing
end
"""
    health!(session::Session, health::AbstractString)::Nothing

Fill out the health status.

```jldoctest
julia> DailyCheckIn.health!(session, "Good")

```
"""
function health!(session::Session, health::AbstractString)
    element = Element(session, "xpath", """//*[@id="text_box_What is your health status?"]""")
    script!(session, "arguments[0].value = arguments[1];", element, "")
    element_keys!(element, health)
    @assert element_attr(element, "value") == health
    nothing
end
"""
    leave!(session::Session, leave::Union{Bool, AbstractString} = false)::Nothing

Fill out the annual leave / personal time off field.

```jldoctest
julia> DailyCheckIn.leave!(session)

julia> DailyCheckIn.leave!(session, true)

julia> DailyCheckIn.leave!(session, "Something came up")

```
"""
function leave!(session::Session, leave::Union{Bool, AbstractString} = false)
    open_options = Element(session, "xpath", """//*[@id="MkRPlP2"]/div/div/div[1]""")
    click!(open_options)
    options = Elements(session, "xpath", """//div[@class="css-11unzgr react-select__menu-list"]/div""")
    choices = element_text.(options)
    if isa(leave, Bool)
        choice = options[findfirst(isequal(leave ? "Yes - Planned Time Off" : "No"), choices)]
        click!(choice)
        @assert element_text(open_options) == (leave ? "Yes - Planned Time Off" : "No")
    else
        choice = options[findfirst(isequal("Other"), choices)]
        click!(choice)
        open_options = Element(session, "xpath", """//*[@id="yDazpp1"]/div/div/div[1]/div[1]""")
        @assert element_text(open_options) == "Other"
        extra = Element(session, "xpath", """//*[@name="2QWMeW9"]""")
        script!(session, "arguments[0].value = arguments[1];", extra, "")
        element_keys!(extra, leave)
        @assert element_attr(extra, "value") == leave
    end
end
end
