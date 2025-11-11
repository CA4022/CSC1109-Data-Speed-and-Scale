import {
    JupyterFrontEnd,
    JupyterFrontEndPlugin
} from '@jupyterlab/application';
import { ILauncher } from '@jupyterlab/launcher';
import { ISettingRegistry } from '@jupyterlab/settingregistry';
import {
    ITerminal,
    Terminal,
    ITerminalTracker
} from '@jupyterlab/terminal';
import { ITranslator } from '@jupyterlab/translation';
import { LabIcon } from '@jupyterlab/ui-components';
import { MainAreaWidget } from '@jupyterlab/apputils';

import {
    shellIcon,
    hiveIcon,
    pigIcon,
    pysparkIcon,
    sparkIcon
} from './icons';

import '../style/index.css';

/**
 * A helper function to add a new terminal command to the launcher.
 *
 * @param app The JupyterFrontEnd application instance.
 * @param launcher The ILauncher instance.
 * @param settingRegistry The ISettingRegistry instance.
 * @param translator The ITranslator instance.
 * @param tracker The ITerminalTracker instance.
 * @param command The unique command ID.
 * @param initialCommand The command to run when the terminal starts (e.g., 'pyspark\r').
 * @param label The text to display in the launcher.
 * @param category The category for the launcher item.
 * @param icon The icon for the launcher item.
 */
async function addToLauncher(
    app: JupyterFrontEnd,
    launcher: ILauncher,
    settingRegistry: ISettingRegistry,
    translator: ITranslator,
    tracker: ITerminalTracker | null,
    command: string,
    initialCommand: string,
    label: string,
    category: string,
    icon: LabIcon
) {
    const { commands, serviceManager } = app;
    const settings = await settingRegistry.load(
        '@jupyterlab/terminal-extension:plugin'
    );
    const baseOptions: Partial<ITerminal.IOptions> = {};
    const keys = Object.keys(
        settings.composite
    ) as (keyof ITerminal.IOptions)[];
    keys.forEach(key => {
        (baseOptions as any)[key] = settings.composite[key];
    });

    commands.addCommand(command, {
        label: label,
        icon: icon,
        execute: async () => {
            const options: Partial<ITerminal.IOptions> = {
                ...baseOptions,
                initialCommand: initialCommand
            };

            try {
                const session = await serviceManager.terminals.startNew();
                const term = new Terminal(session, options, translator);
                term.title.icon = icon;
                term.title.label = label;
                const main = new MainAreaWidget({ content: term, reveal: term.ready });
                app.shell.add(main, 'main', { type: 'Terminal' });
                if (tracker) {
                    void tracker.inject(main);
                }
                app.shell.activateById(main.id);
                return main;
            } catch (e) {
                console.error(`Failed to launch ${label} terminal`, e);
            }
        }
    });

    launcher.add({
        command: command,
        category: category,
        rank: 1
    });
}

const plugin: JupyterFrontEndPlugin<void> = {
    id: 'csc1109-launcher:plugin',
    description:
        'A JupyterLab extension adding icons to the launcher for the CSC1109 lab.',
    autoStart: true,
    requires: [ILauncher, ISettingRegistry, ITranslator],
    optional: [ITerminalTracker],
    activate: (
        app: JupyterFrontEnd,
        launcher: ILauncher,
        settingRegistry: ISettingRegistry,
        translator: ITranslator,
        tracker: ITerminalTracker | null
    ) => {
        console.log('JupyterLab extension csc1109_launcher is activated!');

        const category = 'Console';

        void addToLauncher(
            app,
            launcher,
            settingRegistry,
            translator,
            tracker,
            'csc1109-launcher:launch-shell',
            'python /entrypoint.py\r',
            'Lab Shell',
            category,
            shellIcon
        );

        void addToLauncher(
            app,
            launcher,
            settingRegistry,
            translator,
            tracker,
            'csc1109-launcher:launch-beeline',
            'beeline\r',
            'Hive (beeline)',
            category,
            hiveIcon
        );
        void addToLauncher(
            app,
            launcher,
            settingRegistry,
            translator,
            tracker,
            'csc1109-launcher:launch-grunt',
            'pig\r',
            'Pig (grunt)',
            category,
            pigIcon
        );
        void addToLauncher(
            app,
            launcher,
            settingRegistry,
            translator,
            tracker,
            'csc1109-launcher:launch-pyspark-repl',
            'pyspark\r',
            'PySpark',
            category,
            pysparkIcon
        );
        void addToLauncher(
            app,
            launcher,
            settingRegistry,
            translator,
            tracker,
            'csc1109-launcher:launch-spark-repl',
            'spark-shell\r',
            'Spark',
            category,
            sparkIcon
        );
    }
};

export default plugin;

