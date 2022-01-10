require 'httparty'
require 'nokogiri'
require 'byebug'
require 'money'

def live_conversion_rate
    I18n.enforce_available_locales = false
    url = "https://www.xe.com/currencyconverter/convert/?Amount=1&From=USD&To=GBP"
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    return parsed_page.css('p')[2].text.slice(0, 9)
end


def scraper
    # intialise url to search and array of coin data
    coin_array = Array.new()
    url = "https://coinmarketcap.com/"
    limit = 10
    Money.add_rate("USD", "GBP", live_conversion_rate)
    

    #parse page and use Nokogiri to search through it
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)

    # searches for the tr elements inside tbody
    live_conversion_rate
    rows = parsed_page.css('tbody tr')
    i = 0
    rows.each do |row|
        if i == limit
            return coin_array
        end
        coin = {
            # selects correct data from each row and creates coin attributes, cleans up price data and converts to GBP
            rank: row.css('td')[1].text,
            name: row.css('td')[2].css('p')[0].text,
            price: Money.from_amount(row.css('td')[3].text.gsub(/,/, "").slice(1..-1).to_f, "USD").exchange_to("GBP").format,
            '24hr': row.css('td')[4].text,
            '7d': row.css('td')[5].text,
            marketCap: Money.from_amount(row.css('td')[6].css('span')[1].text.gsub(/,/, "").slice(1..-1).to_f, "USD").exchange_to("GBP").format,
            '24hrvolume': Money.from_amount(row.css('td')[7].css('p')[0].text.gsub(/,/, "").slice(1..-1).to_f, "USD").exchange_to("GBP").format,
            circulatingSupply: row.css('td')[8].text
        }
        byebug
        # pushes coin data to output array
        coin_array << coin
        i = i + 1

        end
end


p scraper
