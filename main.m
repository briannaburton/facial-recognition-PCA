function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 07-Dec-2017 00:44:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
handles.IsTrainPerformed = false;
handles.openedImg.YAxis.Visible = 'off'; % remove y-axis
handles.openedImg.XAxis.Visible = 'off'; % remove x-axis
handles.foundImg.YAxis.Visible = 'off'; % remove y-axis
handles.foundImg.XAxis.Visible = 'off'; % remove x-axis
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openTestImg.
function openTestImg_Callback(hObject, eventdata, handles)
% hObject    handle to openTestImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [FileName,PathName] = uigetfile('*.jpg','Select image');
    if (ischar(FileName) && ischar(PathName))
        img = imread(strcat(PathName, FileName));
        axes(handles.openedImg);
        imshow(img);
        
        handles.openedImg.YAxis.Visible = 'off'; % remove y-axis
        handles.openedImg.XAxis.Visible = 'off'; % remove x-axis
        handles.TestImage = img;
        guidata(hObject,handles);
    end

% --- Executes on button press in trainButton.
function trainButton_Callback(hObject, eventdata, handles)
% hObject    handle to trainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    train_folder = uigetdir('./', 'Select forlder with train images');
    
    if ischar(train_folder)
        n_pca = 50;
        [feature_matrix, proj_matrix, labels, train_imgs] = train(train_folder, n_pca);
        handles.FeatureMatrix = feature_matrix;
        handles.ProjectionMatrix = proj_matrix;
        handles.TrainImages = train_imgs;
        handles.Labels = labels;
        handles.IsTrainPerformed = true;
        guidata(hObject,handles);
    end


% --- Executes on button press in findMatchButton.
function findMatchButton_Callback(hObject, eventdata, handles)
% hObject    handle to findMatchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (handles.IsTrainPerformed)
        index_of_match = find_match(handles.TestImage, handles.FeatureMatrix, handles.ProjectionMatrix);
        axes(handles.foundImg);
        imshow(handles.TrainImages{index_of_match});
        handles.foundImg.YAxis.Visible = 'off'; % remove y-axis
        handles.foundImg.XAxis.Visible = 'off'; % remove x-axis
    else
        msgbox('You need to perform training first', 'Error','error')
    end
