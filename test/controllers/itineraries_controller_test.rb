require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get itineraries_new_url
    assert_response :success
  end

  test "should get create" do
    get itineraries_create_url
    assert_response :success
  end

  test "should get show" do
    get itineraries_show_url
    assert_response :success
  end

  test "should get destroy" do
    get itineraries_destroy_url
    assert_response :success
  end

  test "should get plan" do
    get itineraries_plan_url
    assert_response :success
  end

  test "should get complete" do
    get itineraries_complete_url
    assert_response :success
  end

  test "should get summary" do
    get itineraries_summary_url
    assert_response :success
  end

  test "should get dashboard" do
    get itineraries_dashboard_url
    assert_response :success
  end

  test "should get search" do
    get itineraries_search_url
    assert_response :success
  end
end
