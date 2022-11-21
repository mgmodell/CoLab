import i18n from "./i18n";
import axios from 'axios';
import { addMessage, startTask, endTask, Priorities } from './StatusSlice';
import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";

export interface ProfilesRootState {
  lastRetrieved: Date;
  user: {
  id: number;
  first_name: string;
  last_name: string;
  name: string;
  emails: [{
    email: string;
    primary: boolean;
  }];

  welcomed: boolean;
  is_instructor: boolean;
  is_admin: boolean;
  country: string;
  timezone: string;
  language_id: number;
  theme_id: number;
  admin: boolean;
  researcher: boolean;
  anonymize: boolean;

  gender_id: number;
  date_of_birth: Date;
  home_state_id: number;
  primary_language_id: number;

  school_id: number;
  started_school: Date;
  cip_code_id: number;

  impairment_visual: boolean;
  impairment_auditory: boolean;
  impairment_motor: boolean;
  impairment_cognitive: boolean;
  impairment_other: boolean;

  }

}

const initialState = {
  lastRetrieved: null,
  user: {
  id: -1,
  first_name: '',
  last_name: '',
  name: '',
  emails: [
  ],

  welcomed: false,
  is_instructor: false,
  is_admin: false,
  country: '',
  timezone: 'UTC',
  language_id: 40,
  theme_id: 0,
  admin: false,
  researcher: false,
  anonymize: false,

  gender_id: '__',
  date_of_birth: '' ,
  home_state_id: '',
  primary_language_id: '',

  school_id: '',
  started_school: '',
  cip_code_id: '',

  impairment_visual: false,
  impairment_auditory: false,
  impairment_motor: false,
  impairment_cognitive: false,
  impairment_other: false,

  }
}

const profileSlice = createSlice({
  name: 'profile',
  initialState: initialState,
  reducers: {
    setRetrievedProfile: {
      reducer: (state, action) =>{
        state.user = action.payload;
        state.lastRetrieved = Date.now( );
      }
    },
    setProfile: {
      reducer: (state, action) =>{
        state.user = action.payload;
      }
    },
    setAnonymize: {
      reducer: (state, action) => {
        state.user.anonymize = action.payload;
      }
    },
    setProfileTimezone: {
      reducer: (state, action) =>{
         state.user.timezone = action.payload;
      }
    },
    setProfileTheme: {
      reducer: (state, action) =>{
        state.user.theme_id = action.payload;
      }
    },
    clearProfile: {
      reducer: (state, action) => {
        state = initialState;
      }
    }
  }
})


//Middleware async functions
export const setLocalLanguage = createAsyncThunk( 
  'profile/setLocalLanguage',
  async (language_id: number, thunkAPI ) =>{
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;

    const language = getState().context.lookups.languages
      .find( lang => lang.id === language_id );
    i18n.loadLanguages( language.code );
    i18n.changeLanguage( language.code );
    const user = Object.assign( {}, getState().profile.user );
    user.language_id = language_id;
    dispatch( setProfile( user ) );

  }

)

export const fetchProfile = createAsyncThunk(
  'profile/fetchProfile',
  async (reset: boolean = false, thunkAPI ) => {
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;

    const url = getState().context.endpoints[ 'profile' ]['baseUrl'] + '.json';
    dispatch( startTask( 'init' ) )

    axios.get( url, {
    })
      .then( (response)=>{
        const user: ProfilesRootState = response.data.user;
        dispatch( setRetrievedProfile( user ) );
        dispatch( endTask( 'loading' ) );
      } )
      .catch( error =>{
        console.log( 'error', error );
      })

  }
)

export const persistProfile = createAsyncThunk(
  'profile/persistProfile',
  async( _, thunkAPI ) => {
    dispatch( startTask( 'saving' ) );
    const url = getState().context.endpoints[ 'profile' ]['baseUrl'] + '.json';
    let user: ProfilesRootState = getState().profile.user;


    axios.patch( url, {
      withCredentials: true,
      headers: {
        'Content-Type': 'application/json',
        Accepts: "application/json",
      },
      body: {
        first_name: user.first_name,
        last_name: user.last_name,
        timezone: user.timezone,
        language_id: user.language_id,
        theme_id: user.theme_id,
        researcher: user.researcher,
        gender_id: user.gender_id,
        date_of_birth: user.date_of_birth, 
        primary_language_id: user.primary_language_id,
        country: user.country,
        home_state_id: user.home_state_id,
        school_id: user.school_id,
        cip_code_id: user.cip_code_id,
        started_school: user.started_school,
        impairment_visual: user.impairment_visual,
        impairment_auditory: user.impairment_auditory, 
        impairment_cognitive: user.impairment_cognitive, 
        impairment_motor: user.impairment_motor, 
        impairment_other: user.impairment_other

      } 

    } )
      .then( (data) =>{

        user = data['data']['user'];

        dispatch( setRetrievedProfile( user ) );
        dispatch( endTask( 'loading' ) );
      } )
      .catch( error =>{
        console.log( 'error', error );
      })
  }
)

const {actions, reducer} = profileSlice;
export const { setProfile, setRetrievedProfile, setAnonymize, setProfileTheme, setProfileTimezone, clearProfile } = actions;
export default reducer;