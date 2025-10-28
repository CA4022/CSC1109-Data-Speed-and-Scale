package com.csc1109.lab;

import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class FileSpout extends BaseRichSpout {
    private SpoutOutputCollector collector;
    private BufferedReader reader;
    private HashMap<String, String> pendingTuples;

    @Override
    public void open(
            Map<String, Object> conf, TopologyContext context, SpoutOutputCollector collector) {
        this.collector = collector;
        this.pendingTuples = new HashMap<>();
        try {
            File inputFile = new File((String) conf.get("inputFile"));
            this.reader = new BufferedReader(new FileReader(inputFile));
        } catch (IOException e) {
            throw new RuntimeException("Error reading from file: " + conf.get("inputFile"), e);
        }
    }

    @Override
    public void nextTuple() {
        try {
            String line = this.reader.readLine();
            if (line != null) {
                String msgId = UUID.randomUUID().toString();
                this.pendingTuples.put(msgId, line);
                this.collector.emit(new Values(line), msgId);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void ack(Object msgId) {
        this.pendingTuples.remove((String) msgId);
    }

    @Override
    public void fail(Object msgId) {
        String line = this.pendingTuples.get((String) msgId);
        if (line != null) {
            this.collector.emit(new Values(line), msgId);
        }
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("line"));
    }

    @Override
    public void close() {
        try {
            if (this.reader != null) {
                this.reader.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
