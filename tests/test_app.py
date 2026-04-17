import unittest
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app.app import app

class TestApp(unittest.TestCase):

    def setUp(self):
        self.client = app.test_client()

    def test_home_returns_200(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)

    def test_home_has_version(self):
        response = self.client.get('/')
        data = response.get_json()
        self.assertIn('version', data)

    def test_health_endpoint(self):
        response = self.client.get('/health')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['status'], 'healthy')

if __name__ == '__main__':
    unittest.main()
