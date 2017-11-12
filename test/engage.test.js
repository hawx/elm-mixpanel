import test from 'ava';
import express from 'express';
import * as Elm from './project/main.js';
import { createServer } from 'http';
import { EventEmitter } from 'events';

global.XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

const app = express();

const events = new EventEmitter();
function promiseMe() {
  return new Promise((resolve) => {
    events.on('engage', resolve);
  });
}

app.get('/engage', (req, res) => {
  events.emit('engage', req.query);
  res.send('1');
});

const server = createServer(app);

test.before(() => {
  return new Promise((resolve) => {
    server.listen(3001, function () {
      console.log('listening at :3001');
      resolve();
    });
  });
});

test.serial('$set', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $set: {
      Address: '123 Fake Street'
    }
  });
});

test.serial('$set_once', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_set_once' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $set_once: {
      Address: '123 Fake Street'
    }
  });
});

test.serial('$add', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_add' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $add: {
      'Coins Gathered': 12
    }
  });
});

test.serial('$append', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_append' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $append: {
      'Power Ups': 'Bubble Lead'
    }
  });
});

test.serial('$union', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_union' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $union: {
      'Items Purchased': ['socks', 'shirts']
    }
  });
});

test.serial('$remove', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_remove' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $remove: {
      'Items Purchased': 'socks'
    }
  });
});

test.serial('$unset', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_unset' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $unset: ['Days Overdue']
  });
});

test.serial('$delete', async t => {
  const engaged = promiseMe();

  Elm.Main.worker({ url: 'http://localhost:3001', token: 'what', command: 'engage_delete' });

  const data = Buffer.from((await engaged).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {
    $token: 'what',
    $distinct_id: '12345',
    $delete: ''
  });
});

test.after(() => {
  server.close();
});
