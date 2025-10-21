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

import { hiveIcon, pigIcon, pysparkIcon, sparkIcon } from './icons';

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

    // Fetch the base terminal settings to ensure consistency.
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
            // Create the terminal options with our custom initial command.
            // A carriage return '\r' is used to execute the command.
            const options: Partial<ITerminal.IOptions> = {
                ...baseOptions,
                initialCommand: initialCommand
            };

            try {
                // Start a new terminal session.
                const session = await serviceManager.terminals.startNew();

                // Create the terminal widget with our session and options.
                const term = new Terminal(session, options, translator);
                term.title.icon = icon;
                term.title.label = label;

                // Wrap the terminal in a MainAreaWidget to add it to the shell.
                const main = new MainAreaWidget({ content: term, reveal: term.ready });
                app.shell.add(main, 'main', { type: 'Terminal' });

                // Add the widget to the tracker if available using inject().
                if (tracker) {
                    void tracker.inject(main);
                }

                // Activate the new terminal.
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
        rank: 1 // Adjust rank as needed
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

        // Add launchers for each shell.
        void addToLauncher(
            app,
            launcher,
            settingRegistry,
            translator,
            tracker,
            'hive:launch-beeline',
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
            'pig:launch-grunt',
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
            'spark:launch-pyspark-repl',
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
            'spark:launch-spark-repl',
            'spark-shell\r',
            'Spark',
            category,
            sparkIcon // Corrected from pysparkIcon to sparkIcon
        );
    }
};

export default plugin;


