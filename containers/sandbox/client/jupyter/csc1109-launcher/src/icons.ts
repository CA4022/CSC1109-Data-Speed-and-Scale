import { LabIcon } from '@jupyterlab/ui-components';

import { hiveSVG } from './hive_svg';
import { pigSVG } from './pig_svg';
import { pysparkSVG } from './pyspark_svg';
import { sparkSVG } from './spark_svg';

export const hiveIcon = new LabIcon({
    name: 'hive:icon',
    svgstr: hiveSVG
});

export const pigIcon = new LabIcon({
    name: 'pig:icon',
    svgstr: pigSVG
});

export const pysparkIcon = new LabIcon({
    name: 'pyspark:icon',
    svgstr: pysparkSVG
});

export const sparkIcon = new LabIcon({
    name: 'spark:icon',
    svgstr: sparkSVG
});
