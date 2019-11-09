require 'test_helper'

class CensoringTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    @user = users(:chikuwa)
  end

  # censor by 'Category.censored_by_default' when not logged-in
  test 'censoring test (for guest)' do
    nweet = nweets(:r18g)
    link = nweet.links.first
    get nweet_path(nweet)
    assert_select "a[href=?]", "#collapseVertical#{link.id}"

    nweet = nweets(:kemo)
    link = nweet.links.first
    get nweet_path(nweet)
    assert_select "a[href=?]", "#collapseVertical#{link.id}", false
  end

  test 'censoring test (for user)' do
    login_as(@user)

    nweet = nweets(:kemo)
    link = nweet.links.first
    get nweet_path(nweet)
    assert_select "a[href=?]", "#collapseVertical#{link.id}", false

    put censorings_user_path(@user), params: {"R18G": 1, "KEMO": 1}
    get nweet_path(nweet)
    assert_select "a[href=?]", "#collapseVertical#{link.id}"

    nweet = nweets(:r18g)
    link = nweet.links.first
    get nweet_path(nweet)
    assert_select "a[href=?]", "#collapseVertical#{link.id}"

    put censorings_user_path(@user), params: {"R18G": "0", "KEMO": "0"}
    get nweet_path(nweet)
    assert_select "a[href=?]", "#collapseVertical#{link.id}", false
  end
end
