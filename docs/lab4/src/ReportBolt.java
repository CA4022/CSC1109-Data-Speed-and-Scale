package com.csc1104.lab;

import org.apache.storm.Config;
import org.apache.storm.Constants;
import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Tuple;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class ReportBolt extends BaseRichBolt {
    private HashMap<String, Integer> finalCounts;
    private PrintWriter writer;
    private String outputFile;

    private boolean isTickTuple(Tuple tuple) {
        return tuple.getSourceComponent().equals(Constants.SYSTEM_COMPONENT_ID)
                && tuple.getSourceStreamId().equals(Constants.SYSTEM_TICK_STREAM_ID);
    }

    @Override
    public Map<String, Object> getComponentConfiguration() {
        Config conf = new Config();
        conf.put(Config.TOPOLOGY_TICK_TUPLE_FREQ_SECS, 2);
        return conf;
    }

    @Override
    public void prepare(
            Map<String, Object> topoConf, TopologyContext context, OutputCollector collector) {
        this.finalCounts = new HashMap<>();
        this.outputFile = (String) topoConf.get("outputFile");
        try {
            this.writer = new PrintWriter(new BufferedWriter(new FileWriter(this.outputFile, false)));
        } catch (IOException e) {
            throw new RuntimeException("Error opening file writer for: " + this.outputFile, e);
        }
    }

    @Override
    public void execute(Tuple tuple) {
        if (isTickTuple(tuple)) {
            for (Map.Entry<String, Integer> entry : this.finalCounts.entrySet()) {
                this.writer.println(entry.getKey() + ": " + entry.getValue());
            }
            this.writer.flush();
        } else {
            String word = tuple.getStringByField("word");
            Integer partialCount = tuple.getIntegerByField("count");
            Integer totalCount = this.finalCounts.getOrDefault(word, 0) + partialCount;
            this.finalCounts.put(word, totalCount);
        }
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
    }

    @Override
    public void cleanup() {
        if (this.writer != null) {
            this.writer.close();
        }
    }
}
