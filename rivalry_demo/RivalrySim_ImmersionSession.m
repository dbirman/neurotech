function RivalrySim_ImmersionSession()
    
    %%% Set Parameters %%%
    
    TAU_E = 20;  % Excitatory unit time constant is 20ms
    TAU_I = 11;  % Inhibitory unit time constant is 11ms
    TAU_H = 900; % Adaptation time constant is 900ms
    G = .45;     % Inhibitory strength is .45
    H = .47;     % Adaptation strength is .47

    %%% Initialize variables and stimuli to input to the system %%%
    
    runTime = 60000; % Simulation will run for 20 seconds
    timeStep = 1;    % Simulation will run with 1ms time steps
    currTime = 0;    % Initial time starts at 0ms
    nSteps = ceil(runTime/timeStep); % Number of steps we will simulate
    
    % Both eyes will receive inputs of strength 10 for the duration of the
    % stimulation
    stimuli = zeros(nSteps,2);
    stimuli(1:end,2) = 10.; %%%% What happens if you make this 10.1?
    stimuli(1:end,1) = 10.;

    simRecord = zeros(nSteps,8); %This will hold the results of our simulation

    EVLeft = 0;
    IVLeft = 0;
    HVLeft = 0;

    EVRight = 0;
    IVRight = 0;
    HVRight = 0;

    %%% This is the main loop that runs the simulation %%%
    for step=1:nSteps
        
        %%% Update variables for left eye %%%
        
        INH_ACTLeft = max(stimuli(step,1)-G*IVRight,0); % Calculate total input, accounting for inhibition

        %Compute and implement the change in excitatory activity
        deltaEVLeft = getExcitatoryDelta(EVLeft,INH_ACTLeft,HVLeft,TAU_E);
        EVLeft = EVLeft + deltaEVLeft;

        %Compute and implement the change in inhibitory activity
        deltaIVLeft = getInhibitoryDelta(IVLeft,EVLeft,TAU_I);
        IVLeft = IVLeft + deltaIVLeft;

        %Compute and implement the change in adaptation
        deltaHVLeft = getAdaptationDelta(HVLeft,H*EVLeft,TAU_H);
        HVLeft = HVLeft + deltaHVLeft;

        
        %%% Update variables for right eye %%%
        
        INH_ACTRight = max(stimuli(step,2)-G*IVLeft,0);% Calculate total input, accounting for inhibition

        %Compute and implement the change in excitatory activity
        deltaEVRight = getExcitatoryDelta(EVRight,INH_ACTRight,HVRight,TAU_E);
        EVRight = EVRight + deltaEVRight;

        %Compute and implement the change in inhibitory activity
        deltaIVRight = getInhibitoryDelta(IVRight,EVRight,TAU_I);
        IVRight = IVRight + deltaIVRight;

        %Compute and implement the change in adaptation
        deltaHVRight = getAdaptationDelta(HVRight,H*EVRight,TAU_H);
        HVRight = HVRight + deltaHVRight;

        %%% Record the results %%%
        simRecord(step,1) = EVLeft;
        simRecord(step,2) = IVLeft;
        simRecord(step,3) = HVLeft;
        simRecord(step,4) = EVRight;
        simRecord(step,5) = IVRight;
        simRecord(step,6) = HVRight;
        simRecord(step,7) = INH_ACTLeft;
        simRecord(step,8) = INH_ACTRight;

        currTime = currTime + timeStep; % Update the simulation time
    end
    
    %%% Visualize the results of the simulation %%%
    lw=3;
    
    figure();
    plot(simRecord(:,4),'r','lineWidth',lw); % Show the excitatory value of the RIGHT unit in red
    hold on;
    plot(simRecord(:,6),'m','lineWidth',lw); % Show the adaptation value of the RIGHT unit in magenta
    plot(simRecord(:,1),'b','lineWidth',lw); % Show the excitatory value of the LEFT unit in blue
    plot(simRecord(:,3),'g','lineWidth',lw); % Show the adaptation value of the LEFT unit in green
    %plot(simRecord(:,2),'-k');
    %plot(simRecord(:,5),'-.k');
    
    h_legend = legend('Exc Right','Adapt Right','Exc Left','Adapt Left');
    set(h_legend,'FontSize',16);
    set(h_legend,'position',[.6 .65 0.3 0.25]);
    
    title('Simulation with both inputs = 10','fontSize',16);
    xlabel('Simulation time','fontSize',16);
    ylabel('Value','fontSize',16);
    
    %Plot the simulated percept durations
    plotSimulatedDurations(simRecord);


    %%% This function calculates the update for excitatory values %%%
    function delta = getExcitatoryDelta(currVal,inhibition,adaptation,tau)
        delta = -1.*currVal + 100.*inhibition^2/((10.+adaptation)^2+inhibition^2);
        delta = timeStep*delta/tau; % Adjust for the time step and time constant
    end

    %%% This function calculates the update for inhibitory values %%%
    function delta = getInhibitoryDelta(currVal,excitation,tau)
        delta = -1.*currVal + excitation;
        delta = timeStep*delta/tau; % Adjust for the time step and time constant
    end

    %%% This function calculates the update for adaptation %%%
    function delta = getAdaptationDelta(currVal,excitation,tau)
        delta = -1.*currVal + excitation;
        %%%% What could you do here to create varied percept durations? %%%%
        delta = timeStep*delta/tau; % Adjust for the time step and time constant
    end

    %%% This function plots the simulated percept durations
    function plotSimulatedDurations(simRecord)
        resps = simRecord(:,1)>simRecord(:,4); %Compare the activity of left and right exc units
        resps = resps'; %Transpose
        timestamp = [find(diff([-1 resps]) ~= 0)]; % Find where the response changes
        timestamp(end+1) = size(resps,2);
        durations = diff(timestamp); % Find perceptual durations

        figure();
        hist(durations); % Plot the durations
        title('Simulated Percept durations')
        xlabel('Duration (s)');
        ylabel('Count (n)');
        xlim([0 max(durations)+1]);
    end
end