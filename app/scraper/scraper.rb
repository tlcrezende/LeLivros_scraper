require 'selenium'
require 'selenium-webdriver'
require 'byebug'

class Scraper
  headless = false
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--window-size=1920,1080") if headless == true
  options.add_argument("--start-maximized") if headless == true
  options.add_argument("--disable-infobars ")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-gpu")
  options.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
  options.add_argument('--headless') if headless == true
  @driver = Selenium::WebDriver.for :chrome, options: options
  options = {
    headless: headless
  }

  @wait = Selenium::WebDriver::Wait.new(timeout: 10)
  output = []

  for i in 0..5 
    @driver.get 'https://lelivros.digital' if i == 0
  
    link_book = @wait.until do
      @driver.find_elements(:css, 'a[class=" button product_type_simple"]')
    end
    count = 0
      
    link_book.each do |book|
      @driver.execute_script("window.open('#{book.attribute("href")}');")
      sleep 2
      @driver.switch_to.window(@driver.window_handles[1])
      titulo = @wait.until do
        @driver.find_element(:css, 'span[class="current"]')
      end
      nome_livro = titulo.text
  
      descricao = @wait.until do
        @driver.find_element(:css, 'div[id="tab-description"]')
      end
      texto = descricao.find_elements(:tag_name,'p')
      texto = descricao.find_elements(:css, 'div[class="sinopse"]') if texto.empty?
      desc = ""
      texto.each do |t|
        desc << t.text
        desc << " "
      end
      @driver.close
      @driver.switch_to.window(@driver.window_handles[0])
      count += 1
      output << {
        nome: nome_livro,
        descricao: desc
      }
      p "Adicionado livro: #{nome_livro}"
      p "Adicionado descricao: #{desc[0..15]}"
    end
    sleep 2
    @driver.get "https://lelivros.digital/page/#{i+2}/"
  end
  p output.count 

  sleep 11


end
