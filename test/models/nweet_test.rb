require 'test_helper'

class NweetTest < ActiveSupport::TestCase
  def setup
    @user = users(:chikuwa)
    @new_user = users(:girl)
    @nweet = @user.nweets.build(did_at: Time.zone.now)
  end

  test 'should be valid' do
    assert @nweet.valid?
  end

  test 'user id should be present' do
    @nweet.user_id = nil
    assert_not @nweet.valid?
  end

  test 'did_at should be present (I mean, past)' do
    @nweet.did_at = nil
    assert_not @nweet.valid?

    @nweet.did_at = 1.day.since
    assert_not @nweet.valid?

    @nweet.did_at = 1.hour.ago
    assert @nweet.valid?
  end

  test 'nweet should be most recent first' do
    assert_equal nweets(:modasho), Nweet.first
    assert_equal nweets(:saytwo), Nweet.last
  end

  test 'statement should be valid' do
    @nweet.statement = nil
    assert @nweet.valid?

    @nweet.statement = 'a' * 150
    assert_not @nweet.valid?

    @nweet.statement = '誰だ今の'
    assert @nweet.valid?

    # utf8mb4
    @nweet.statement = '🕦 💍 📱 🏎 👠 🚼 🎭 👢 🏜 📖'
    assert @nweet.valid?
  end

  test 'url_digest must be generated' do
    new_nweet = @user.nweets.create(did_at: Time.zone.now)
    assert_not_empty new_nweet.url_digest
  end

  test 'associated favorites must be destroyed' do
    @new_user.save
    @new_user.favorites.create!(nweet: @nweet)
    assert_difference 'Favorite.count', -1 do
      @nweet.destroy
    end
  end

  test 'url infos in nweet must be fetched' do
    url = 'https://www.youtube.com/user/HikakinTV'
    assert_difference 'Link.count', 1 do
      @user.nweets.create(did_at: 10.minutes.ago, statement: url)
    end

    link = Link.find_by(url: url)
    assert_equal url, link.url
    assert_match 'Hikakin', link.title
    assert_match 'ヒカキン', link.description

    nweet_again = nil
    # Linkの再生成はしない
    assert_no_difference 'Link.count' do
      nweet_again = @user.nweets.create(did_at: Time.zone.now, statement: url)
    end

    # けど関連付けはされてる
    assert_equal link, nweet_again.links.first
  end

  test 'tags in nweet must be generated as category' do
    str = "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=75609372 #R18G #2D"
    nweet = @user.nweets.create(did_at: Time.zone.now, statement: str)
    link = nweet.links.first

    assert link.categories.exists?(name: 'R18G', censored_by_default: true)
    assert link.categories.exists?(name: '2D', censored_by_default: false)
  end
end
