<?php

declare(strict_types=1);

chdir(dirname(__DIR__));
require 'vendor/autoload.php';

try {
    $clientPrimaryPreferred = new \MongoDB\Client(
        'mongodb://node0.mongodb.local:27017,node1.mongodb.local:27017,node2.mongodb.local:27017?replicaSet=cluster&connectTimeoutMS=2000&readPreference=primaryPreferred&serverSelectionTryOnce=false',
        [],
        //force usage of assoc instead of stdClass objects when returning data from mongodb
        ['typeMap' => ['root' => 'array', 'document' => 'array', 'array' => 'array']]
    );

    $clientSecondaryPreferred = new \MongoDB\Client(
        'mongodb://node0.mongodb.local:27017,node1.mongodb.local:27017,node2.mongodb.local:27017?replicaSet=cluster&connectTimeoutMS=2000&readPreference=secondaryPreferred&serverSelectionTryOnce=false',
        [],
        //force usage of assoc instead of stdClass objects when returning data from mongodb
        ['typeMap' => ['root' => 'array', 'document' => 'array', 'array' => 'array']]
    );

    $database = 'testing';

    echo 'Insert successful: ' . var_export($clientPrimaryPreferred->selectCollection($database, 'write_test')->insertOne(['text' => uniqid()])->isAcknowledged());

    usleep(200);

    echo 'Count: ' . var_export(count($clientSecondaryPreferred->selectCollection($database, 'write_test')->find()->toArray()));

} catch (\Throwable $e) {
    $fh = fopen('php://stderr', 'a');
    fwrite($fh, $e->getMessage() . PHP_EOL . $e->getTraceAsString());
    fclose($fh);
}
