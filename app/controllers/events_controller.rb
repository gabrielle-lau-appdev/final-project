require 'open-uri'
class EventsController < ApplicationController

#I add this for filter


  def index
    # @events = Event.all
    @q = Event.all.ransack(params[:q])
    @events = @q.result(distinct: true)

    render("event_templates/index.html.erb")
  end

  def show
    @event = Event.find(params.fetch("id_to_display"))
    
    #for weather forecast
    # @street_address = params[:user_street_address]
    @street_address = @event.city
    @url_safe_street_address = URI.encode(@street_address)

    @url = "https://maps.googleapis.com/maps/api/geocode/json?address="+@url_safe_street_address.to_s
    @parsed_result = JSON.parse(open(@url).read)
    @latitude = @parsed_result.dig("results", 0, "geometry", "location", "lat").to_s
    @longitude = @parsed_result.dig("results", 0, "geometry", "location", "lng").to_s

    @url2="https://api.darksky.net/forecast/2c822d92f31656e2262fa7f6429ef27a/"+@latitude.to_s+","+@longitude.to_s
    @parsed_data = JSON.parse(open(@url2).read)
    
    @current_temperature = @parsed_data.dig("currently", "temperature").to_s

    @current_summary = @parsed_data.dig("currently", "summary").to_s

    @summary_of_next_sixty_minutes = @parsed_data.dig("minutely", "summary").to_s

    @summary_of_next_several_hours = @parsed_data.dig("hourly", "summary").to_s

    @summary_of_next_several_days = @parsed_data.dig("daily", "summary").to_s
  
    render("event_templates/show.html.erb")
  end

  def new_form
    render("event_templates/new_form.html.erb")
  end

  def create_row
    @event = Event.new

    @event.city = params.fetch("city")
    @event.event_name = params.fetch("event_name")
    @event.date = params.fetch("date")
    @event.description = params.fetch("description")
    @event.host_id = params.fetch("host_id")
    @event.image = params[:image]
    
    if @event.valid?
      @event.save

      redirect_to("/events", :notice => "Event created successfully.")
    else
      render("event_templates/new_form.html.erb")
    end
  end

  def edit_form
    @event = Event.find(params.fetch("prefill_with_id"))

    render("event_templates/edit_form.html.erb")
  end

  def update_row
    @event = Event.find(params.fetch("id_to_modify"))

    @event.city = params.fetch("city")
    @event.event_name = params.fetch("event_name")
    @event.date = params.fetch("date")
    @event.description = params.fetch("description")
    @event.host_id = params.fetch("host_id")

    if @event.valid?
      @event.save

      redirect_to("/events/#{@event.id}", :notice => "Event updated successfully.")
    else
      render("event_templates/edit_form.html.erb")
    end
  end

  def destroy_row
    @event = Event.find(params.fetch("id_to_remove"))

    @event.destroy

    redirect_to("/events", :notice => "Event deleted successfully.")
  end
end
