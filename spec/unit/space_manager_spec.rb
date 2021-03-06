require "space_manager"
require "space"
require "booking"
require "booking_management"

describe SpaceManager do
  let(:space_double) { double :space, name: "london flat", price: "35", description: "a beautiful flat in central london lol", space_id: nil, user_id: nil }

  let(:space_double_two) { double :space, name: "manchester flat", price: "30", description: "a cottage in the outskirt", space_id: nil, user_id: nil }

  describe "#.create" do
    it "creates new space with Space class passed in as parameter" do
      user = add_test_user()
      space = SpaceManager.create(Space.new("london flat", "35", "a beautiful flat in central london lol", user))
      expect(space.name).to eq "london flat"
      expect(space.price).to eq "$35.00"
      expect(space.description).to eq "a beautiful flat in central london lol"
    end
  end

  describe "#.all" do
    it "returns a list of all the spaces" do
      user = add_test_user()
      space = SpaceManager.create(Space.new("london flat", "35", "a beautiful flat in central london lol", user))
      space2 = SpaceManager.create(Space.new("manchester flat", "35", "A flat", user))
      list_spacemanager_all = SpaceManager.all
      expect(list_spacemanager_all[1].name).to eq "manchester flat"
    end
  end

  describe "#.availability" do
    it "returns the days available in a selected month" do
      user = add_test_user()
      space_false = add_test_space(user)
      space_true = add_test_space_true(user)
      booking_false = BookingManagement.request(Booking.new(space_false, user, "2020-09-20"))
      booking_true = BookingManagement.request(Booking.new(space_true, user, "2020-09-21", true))
      BookingManagement.confirm_booking(booking_true.booking_id, true)
      dates = SpaceManager.availability(space_true, Date.new(2020, 9))
      expect(dates.length).to eq 29
      expect(dates[0]).to eq Date.new(2020, 9, 1)
    end
  end

  describe "#.view_space" do
    it " view a single space" do
      user = add_test_user()
      space = add_test_space(user)
      viewed_space = SpaceManager.view_space(space)
      expect(viewed_space.name).to eq "Buckingham Palace"
    end
  end

  describe "#.month_conversion" do
    it "converts a month string into a Date object" do
      test = SpaceManager.month_conversion("september")
      expect(test).to eq Date.new(2020, 9, 1)
    end
  end
end
