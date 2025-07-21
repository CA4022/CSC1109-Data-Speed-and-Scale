package com.csc1104.lab;

import org.apache.storm.Config;
import org.apache.storm.StormSubmitter;
import org.apache.storm.topology.TopologyBuilder;
import org.apache.storm.tuple.Fields;

public class WordCountTopology {
    public static void main(String[] args) throws Exception {
        TopologyBuilder builder = new TopologyBuilder();
        Config conf = new Config();

        builder.setSpout("spout", new FileSpout());
        builder.setBolt("split", new SplitLineBolt(), 4).shuffleGrouping("spout");
        builder.setBolt("count", new WordCountBolt(), 4)
                .fieldsGrouping("split", new Fields("word"));
        builder.setBolt("report", new ReportBolt())
                .globalGrouping("count");

        if (args.length < 2) {
            System.err.println("Usage: WordCountTopology <input-file> <output-file>");
            System.exit(1);
        }
        conf.put("inputFile", args[0]);
        conf.put("outputFile", args[1]);
        conf.setNumWorkers(4);

        StormSubmitter.submitTopology("word-count", conf, builder.createTopology());
    }
}
