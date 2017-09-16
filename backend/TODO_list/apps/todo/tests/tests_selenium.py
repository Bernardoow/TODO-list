from django.test import LiveServerTestCase
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait


class TasksTestCase(LiveServerTestCase):

    def setUp(self):
        self.selenium = webdriver.Firefox()
        super(TasksTestCase, self).setUp()

    def tearDown(self):
        self.selenium.quit()
        super(TasksTestCase, self).tearDown()

    def test_create_task(self):
        selenium = self.selenium
        selenium.get('http://127.0.0.1:8000/Main.elm')
        selenium.implicitly_wait(5)
        btnCreateNewTask = selenium.find_element_by_id('btnCreateNewTask')
        btnCreateNewTask.click()
        selenium.implicitly_wait(5)
        inputTitle = selenium.find_element_by_id('inputTitle')
        inputTitle.send_keys('Teste Title')

        inputDescription = selenium.find_element_by_id('inputDescription')
        inputDescription.send_keys('Teste Description')

        btnSave = selenium.find_element_by_id('btnSave')
        btnSave.click()

        selenium.implicitly_wait(5)

        title = selenium.find_element_by_css_selector('.titleBoard')
        self.assertIsNotNone(title)

    def test_update_task(self):
        selenium = self.selenium
        selenium.get('http://127.0.0.1:8000/Main.elm')
        selenium.implicitly_wait(5)
        btnDetail = selenium.find_element(By.XPATH, '//button[text()="Detalhes"]')
        btnDetail.click()
        selenium.implicitly_wait(5)
        inputTitle = selenium.find_element_by_id('inputTitle')
        inputTitle.send_keys('Teste Title')

        inputDescription = selenium.find_element_by_id('inputDescription')
        inputDescription.send_keys('Teste Description')

        btnSave = selenium.find_element_by_id('btnSave')
        btnSave.click()

        selenium.implicitly_wait(5)

        title = selenium.find_element_by_css_selector('.titleBoard')
        self.assertIsNotNone(title)
