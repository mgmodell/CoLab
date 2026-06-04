module UiHelpers
  UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  LOWERCASE = "abcdefghijklmnopqrstuvwxyz".freeze

  def xpath_literal(value)
    return %("#{value}") unless value.include?('"')
    return %('#{value}') unless value.include?("'")

    %(concat("#{value.split('"').join('", \'"\', "')}"))
  end

  def xpath_ci_contains(text_expr, value)
    lowered = xpath_literal(value.downcase)
    "contains(translate(normalize-space(#{text_expr}), '#{UPPERCASE}', '#{LOWERCASE}'), #{lowered})"
  end

  def open_main_menu
    wait_for_render

    menu_xpath = [
      "//*[@id='main-menu-button']",
      "//button[@aria-label='Main Menu']",
      "//*[contains(@class,'mainNav')]//button[1]"
    ].join(" | ")

    find(:xpath, menu_xpath, match: :first, wait: 10, visible: :all).click
  end

  def click_named_tab(tab_name)
    wait_for_render

    tab_xpath = [
      "//*[@role='tablist']//*[@role='tab' and #{xpath_ci_contains('.', tab_name)}]",
      "//*[@role='tablist']//a[#{xpath_ci_contains('.', tab_name)}]",
      "//*[@role='tablist']//button[#{xpath_ci_contains('.', tab_name)}]"
    ].join(" | ")

    find(:xpath, tab_xpath, match: :first, wait: 10).click
    wait_for_render
  end

  def enable_table_view_option(option_name)
    ack_messages

    toggle_xpath = [
      "//div[@data-pc-name='multiselect']",
      "//div[contains(@class,'p-multiselect')]",
      "//button[@aria-label='View Columns']"
    ].join(" | ")
    option_xpath = "//ul[@role='listbox']//li[#{xpath_ci_contains('.', option_name)}]"

    4.times do
      find(:xpath, toggle_xpath, match: :first, wait: 10, visible: :all).click
      break if has_xpath?(option_xpath, wait: 2)
    end

    option = find(:xpath, option_xpath, wait: 10)
    checkbox = option.first(
      :xpath,
      ".//*[@role='checkbox'] | .//div[@data-p-highlight] | .//input[@type='checkbox']",
      visible: :all
    )

    if checkbox.nil?
      option.click
    elsif checkbox[:"data-p-highlight"] == "false" || checkbox[:"aria-checked"] == "false"
      checkbox.click
    end

    send_keys :escape
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    send_keys :escape
  end
end

World(UiHelpers)
