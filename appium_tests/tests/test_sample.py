from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from appium_flutter_finder.flutter_finder import FlutterFinder, FlutterElement
import json
import time
import os

def main():
    # Load configuration from file
    config_path = os.path.join(os.path.dirname(__file__), '../configs/config.json')
    with open(config_path) as config_file:
        config = json.load(config_file)

    # Extract serverUrl and remove it from config to avoid passing it to webdriver.Remote
    server_url = config.pop("serverUrl")

    # Set desired capabilities using AppiumOptions
    options = AppiumOptions()
    options.set_capability("platformName", config["platformName"])
    options.set_capability("platformVersion", config["platformVersion"])
    options.set_capability("deviceName", config["deviceName"])
    options.set_capability("app", config["app"])
    options.set_capability("automationName", config["automationName"])
    options.set_capability("wdaLaunchTimeout", config.get("wdaLaunchTimeout", 120000))
    options.set_capability("useNewWDA", True)

    driver = webdriver.Remote(command_executor=server_url, options=options)
    flutter_finder = FlutterFinder()

    # Wait for the app to launch
    time.sleep(20)

    try:
        # Verify if we are on the login page by checking for the presence of email field
        email_field = flutter_finder.by_value_key('email_field_key')
        password_field = flutter_finder.by_value_key('password_field_key')
        login_button = flutter_finder.by_value_key('login_button_key')

        # Find and interact with elements
        email_element = driver.find_element(AppiumBy.FLUTTER, email_field)
        password_element = driver.find_element(AppiumBy.FLUTTER, password_field)
        login_element = driver.find_element(AppiumBy.FLUTTER, login_button)

        # Perform actions
        email_element.send_keys("test@example.com")
        password_element.send_keys("password")
        login_element.click()
        
        print("Login page elements are present and actions performed")

    except Exception as e:
        print(f"Error finding login page elements: {e}")

    driver.quit()

if __name__ == "__main__":
    main()
