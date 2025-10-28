import { LabIcon } from '@jupyterlab/ui-components';

import hiveSVG from '../style/hive.svg';
import pigSVG from '../style/pig.svg';
import pysparkSVG from '../style/pyspark.svg';
import sparkSVG from '../style/spark.svg';

export const hiveIcon = new LabIcon({
    name: 'csc1109-launcher:hive-icon',
    svgstr: hiveSVG
});

export const pigIcon = new LabIcon({
    name: 'csc1109-launcher:pig-icon',
    svgstr: pigSVG
});

export const pysparkIcon = new LabIcon({
    name: 'csc1109-launcher:pyspark-icon',
    svgstr: pysparkSVG
});

export const sparkIcon = new LabIcon({
    name: 'csc1109-launcher:spark-icon',
    svgstr: sparkSVG
});
