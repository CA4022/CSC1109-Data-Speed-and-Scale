package com.csc1104.lab;

import org.apache.storm.Config;
import org.apache.storm.Constants;
import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WordCountBolt extends BaseRichBolt {
    private static final int BATCH_SIZE = 64; // This should give ~2kb packet size
    private HashMap<String, Integer> counts;
    private OutputCollector collector;
    private List<Tuple> batch;

    @Override
    public void prepare(Map<String, Object> topoConf, TopologyContext context, OutputCollector collector) {
        this.counts = new HashMap<>();
        this.collector = collector;
        this.batch = new ArrayList<>(BATCH_SIZE);
    }

    private boolean isTickTuple(Tuple tuple) {
        return tuple.getSourceComponent().equals(Constants.SYSTEM_COMPONENT_ID)
                && tuple.getSourceStreamId().equals(Constants.SYSTEM_TICK_STREAM_ID);
    }

    @Override
    public Map<String, Object> getComponentConfiguration() {
        Config conf = new Config();
        conf.put(Config.TOPOLOGY_TICK_TUPLE_FREQ_SECS, 1);
        return conf;
    }

    @Override
    public void execute(Tuple tuple) {
        if (isTickTuple(tuple)) {
            flushCounts();
        } else {
            this.batch.add(tuple);

            String word = tuple.getStringByField("word");
            Integer count = this.counts.getOrDefault(word, 0) + 1;
            this.counts.put(word, count);

            if (this.counts.size() >= BATCH_SIZE) {
                this.flushCounts();
            }
        }
    }

    private void flushCounts() {
        for (Map.Entry<String, Integer> entry : this.counts.entrySet()) {
            this.collector.emit(new Values(entry.getKey(), entry.getValue()));
        }

        for (Tuple t : this.batch) {
            this.collector.ack(t);
        }

        this.counts.clear();
        this.batch.clear();
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word", "count"));
    }
}
