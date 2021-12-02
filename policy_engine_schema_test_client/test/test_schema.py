#! /usr/bin/env python3

from datetime import datetime
import unittest
import policy_engine
import os
from datetime import date
from pymysql import connect, cursors

class test_schema(unittest.TestCase):
  def __init__(self):
    self.conn = connect(
      host=os.environ.get('DB_HOST'),
      user=os.environ.get('DB_USER'),
      password=os.environ.get('DB_PASS'),
      database=os.environ.get('DB_NAME'),
      cursorclass=cursors.DictCursor
    )

  def setUp(self):
    
    cursor = self.conn.cursor()
    cursor.execute("insert into sites (id, name, tag) values (%s, %s,  %s);",(1, 'Site1','site_1'))
    cursor.execute("insert into policies (id, name, description, fallback) values (%s, %s, %s, %s);",(1,'Policy_1','whatever', False))
    cursor.execute("insert into rules (request_attribute, operator, value, policy_id) values (%s, %s, %s, %s);",('Tunnel-Type','equals', "Vlan", 1))
    cursor.execute("insert into responses (response_attribute, value, policy_id) values (%s, %s, %s);",('Reply-Message','Hello', 1))
    cursor.execute("insert into site_policies (site_id, policy_id, priority) values (%s, %s, %s);",(1, 1, 1))

  def tearDown(self):

    cursor = self.conn.sursor()
    cursor.execute_many(["delete from rules;", "delete from responses;", "delete from site_policies;", "delete from policies;", "delete from sites;"])
    self.conn.commit()





    #  t.string "operator", null: false
    # t.text "value", null: false
    # t.bigint "policy_id", null: false
    # t.string "request_attribute", null: false
    # t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    # t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    # t.index ["policy_id"], name: "index_rules_on_policy_id"
    
    
    connection.commit()

  def test_(self):
    payload = {'EAP-Type': 'TLS', 'Client-Shortname': 'site_1'}
    result = policy_engine.post_auth(payload)
    self.assertEqual(result, ('OK', {'reply': ()}))

if __name__ == '__main__':
    unittest.main()