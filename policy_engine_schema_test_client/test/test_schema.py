#! /usr/bin/env python3

from datetime import datetime
import unittest
import policy_engine
import os
from datetime import date
from pymysql import connect, cursors

class test_schema(unittest.TestCase):
  def connectDb(self):
    return connect(
      host=os.environ.get('DB_HOST'),
      user=os.environ.get('DB_USER'),
      password=os.environ.get('DB_PASS'),
      database=os.environ.get('DB_NAME'),
      cursorclass=cursors.DictCursor
    )


  def setUp(self):
    conn = self.connectDb()

    cursor = conn.cursor()
    cursor.execute("insert into sites (id, name, tag) values (%s, %s,  %s);",(1, 'Site1','site_1'))
    cursor.execute("insert into policies (id, name, description, fallback) values (%s, %s, %s, %s);",(1,'Fallback Policy','whatever', True))
    cursor.execute("insert into policies (id, name, description, fallback, rule_count) values (%s, %s, %s, %s, %s);",(2,'Non-fallback Policy','whatever', False, 1))
    cursor.execute("insert into responses (response_attribute, value, policy_id) values (%s, %s, %s);",('Reply-Message','Hello, this is fallback', 1))
    cursor.execute("insert into responses (response_attribute, value, policy_id) values (%s, %s, %s);",('Reply-Message','Bye, this is not fallback', 2))
    cursor.execute("insert into rules (request_attribute, operator, value, policy_id) values (%s, %s, %s, %s);",('Tunnel-Type','equals', "VLAN", 2))
    cursor.execute("insert into site_policies (site_id, policy_id, priority) values (%s, %s, %s);",(1, 1, None))
    cursor.execute("insert into site_policies (site_id, policy_id, priority) values (%s, %s, %s);",(1, 2, 1))
    conn.commit()

  def tearDown(self):
    conn = self.connectDb()

    cursor = conn.cursor()

    for table in ['rules', 'responses', 'site_policies', 'policies', 'sites']:
      cursor.execute(f"DELETE FROM `{table}`")

    conn.commit()


  def test_fallback_policy(self):
    print("test policy engine hits fallback policy")
    payload = {'EAP-Type': 'TLS', 'Client-Shortname': 'site_1'}
    result = policy_engine.post_auth(payload)
    self.assertEqual(result, ('OK', {'reply': (('Reply-Message', 'Hello, this is fallback'),)}))


  def test_policy(self):
    print("test policy engine hits policy")
    payload = {'EAP-Type': 'TLS', 'Client-Shortname': 'site_1', 'Tunnel-Type': 'VLAN'}
    result = policy_engine.post_auth(payload)
    self.assertEqual(result, ('OK', {'reply': (('Reply-Message', 'Bye, this is not fallback'),)}))


if __name__ == '__main__':
    unittest.main()
