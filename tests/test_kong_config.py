"""
Simple unit tests for Kong Gateway configuration validation.
"""

import unittest
import yaml
import os


class TestKongConfig(unittest.TestCase):
    """Test cases for validating kong.yml configuration."""

    @classmethod
    def setUpClass(cls):
        """Load the Kong configuration file once for all tests."""
        config_path = os.path.join(os.path.dirname(__file__), '..', 'kong.yml')
        with open(config_path, 'r') as f:
            cls.config = yaml.safe_load(f)

    def test_config_format_version(self):
        """Test that config has the correct format version."""
        self.assertIn('_format_version', self.config)
        self.assertEqual(self.config['_format_version'], '3.0')

    def test_services_exist(self):
        """Test that services are defined."""
        self.assertIn('services', self.config)
        self.assertIsInstance(self.config['services'], list)
        self.assertGreater(len(self.config['services']), 0)

    def test_all_services_have_required_fields(self):
        """Test that each service has name and url."""
        for service in self.config['services']:
            self.assertIn('name', service)
            self.assertIn('url', service)
            self.assertIsInstance(service['name'], str)
            self.assertIsInstance(service['url'], str)

    def test_all_services_have_routes(self):
        """Test that each service has at least one route."""
        for service in self.config['services']:
            self.assertIn('routes', service)
            self.assertIsInstance(service['routes'], list)
            self.assertGreater(len(service['routes']), 0)

    def test_routes_have_paths(self):
        """Test that each route has paths defined."""
        for service in self.config['services']:
            for route in service['routes']:
                self.assertIn('paths', route)
                self.assertIsInstance(route['paths'], list)
                self.assertGreater(len(route['paths']), 0)

    def test_service_names_unique(self):
        """Test that service names are unique."""
        service_names = [s['name'] for s in self.config['services']]
        self.assertEqual(len(service_names), len(set(service_names)))

    def test_route_names_unique(self):
        """Test that route names are unique across all services."""
        route_names = []
        for service in self.config['services']:
            for route in service['routes']:
                if 'name' in route:
                    route_names.append(route['name'])
        self.assertEqual(len(route_names), len(set(route_names)))

    def test_plugins_exist(self):
        """Test that plugins are defined."""
        self.assertIn('plugins', self.config)
        self.assertIsInstance(self.config['plugins'], list)
        self.assertGreater(len(self.config['plugins']), 0)

    def test_cors_plugin_configured(self):
        """Test that CORS plugin is configured."""
        plugin_names = [p['name'] for p in self.config['plugins']]
        self.assertIn('cors', plugin_names)

    def test_url_format(self):
        """Test that service URLs are properly formatted."""
        for service in self.config['services']:
            url = service['url']
            self.assertTrue(
                url.startswith('http://') or url.startswith('https://'),
                f"Service {service['name']} URL does not start with http:// or https://"
            )

    def test_route_paths_start_with_slash(self):
        """Test that all route paths start with a forward slash."""
        for service in self.config['services']:
            for route in service['routes']:
                for path in route['paths']:
                    self.assertTrue(
                        path.startswith('/'),
                        f"Route path '{path}' in service '{service['name']}' does not start with '/'"
                    )


if __name__ == '__main__':
    unittest.main()
