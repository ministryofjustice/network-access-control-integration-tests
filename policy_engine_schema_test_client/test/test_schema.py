#! /usr/bin/env python3

from datetime import datetime
import unittest
import policy_engine
import os
from datetime import date
from pymysql import connect, cursors

class test_schema(unittest.TestCase):
  def setUp(self):
    connection = connect(host=os.environ.get('DB_HOST'),
                        user=os.environ.get('DB_USER'),
                        password=os.environ.get('DB_PASS'),
                        database=os.environ.get('DB_NAME'),
                        cursorclass=cursors.DictCursor)

    cursor = connection.cursor()
    cursor.execute("insert into sites (name, tag) values (%s, %s);",('Site1','site_1'))
    cursor.execute("insert into policies (name, description, fallback) values (%s, %s, %s);",('Policy_1','whatever', False))
    connection.commit()

  def test_(self):
    payload = {'EAP-Type': 'TLS', 'Client-Shortname': 'site_1'}
    result = policy_engine.post_auth(payload)
    self.assertEqual(result, ('OK', {'reply': ()}))

if __name__ == '__main__':
    unittest.main()