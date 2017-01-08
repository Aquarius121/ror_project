--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    user_id integer,
    follower_id integer,
    activity_date date,
    activity_text text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: affiliates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE affiliates (
    id integer NOT NULL,
    club_id integer,
    user_id integer,
    active boolean,
    start timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: affiliates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE affiliates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: affiliates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE affiliates_id_seq OWNED BY affiliates.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE announcements (
    id integer NOT NULL,
    title character varying,
    body text,
    club_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE announcements_id_seq OWNED BY announcements.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    gallery_id integer
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: card_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE card_transactions (
    id integer NOT NULL,
    raw_data character varying(4096),
    processed_at timestamp without time zone
);


--
-- Name: card_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE card_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: card_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE card_transactions_id_seq OWNED BY card_transactions.id;


--
-- Name: challenges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE challenges (
    id integer NOT NULL,
    name character varying,
    description character varying,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    target double precision,
    featured boolean,
    prize character varying,
    sponsor character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rules character varying,
    location character varying
);


--
-- Name: challenges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE challenges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: challenges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE challenges_id_seq OWNED BY challenges.id;


--
-- Name: club_riding_preferences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE club_riding_preferences (
    id integer NOT NULL,
    club_id integer,
    riding_preference_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: club_riding_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE club_riding_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: club_riding_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE club_riding_preferences_id_seq OWNED BY club_riding_preferences.id;


--
-- Name: club_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE club_types (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: club_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE club_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: club_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE club_types_id_seq OWNED BY club_types.id;


--
-- Name: clubs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clubs (
    id integer NOT NULL,
    title character varying,
    logo character varying,
    description text,
    location character varying,
    privacy_id integer,
    club_type_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    owner_id integer,
    logo_id integer,
    website character varying,
    url character varying
);


--
-- Name: clubs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clubs_id_seq OWNED BY clubs.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    related_id integer,
    user_id integer,
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conditions (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conditions_id_seq OWNED BY conditions.id;


--
-- Name: coupons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coupons (
    id integer NOT NULL,
    premium_plan_id integer,
    code character varying,
    discount integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying
);


--
-- Name: coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coupons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coupons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coupons_id_seq OWNED BY coupons.id;


--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE friendships (
    id integer NOT NULL,
    follower_id integer,
    user_id integer,
    active boolean,
    date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendships_id_seq OWNED BY friendships.id;


--
-- Name: galleries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE galleries (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    route_id integer
);


--
-- Name: galleries_attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE galleries_attachments (
    id integer NOT NULL,
    gallery_id integer,
    attachment_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: galleries_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE galleries_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: galleries_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE galleries_attachments_id_seq OWNED BY galleries_attachments.id;


--
-- Name: galleries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE galleries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: galleries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE galleries_id_seq OWNED BY galleries.id;


--
-- Name: group_rides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_rides (
    id integer NOT NULL,
    route_id integer,
    club_id integer,
    planned_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_rides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_rides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_rides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_rides_id_seq OWNED BY group_rides.id;


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invites (
    id integer NOT NULL,
    firstname character varying,
    lastname character varying,
    email character varying,
    code character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invites_id_seq OWNED BY invites.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE members (
    id integer NOT NULL,
    club_id integer,
    user_id integer,
    active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: premium_plans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE premium_plans (
    id integer NOT NULL,
    name character varying,
    price double precision,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    period integer,
    label character varying,
    archived boolean DEFAULT false NOT NULL,
    role_id integer DEFAULT 3
);


--
-- Name: premium_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE premium_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: premium_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE premium_plans_id_seq OWNED BY premium_plans.id;


--
-- Name: privacies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE privacies (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: privacies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE privacies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: privacies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE privacies_id_seq OWNED BY privacies.id;


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ranks (
    id integer NOT NULL,
    challenge_id integer,
    user_id integer,
    rank integer,
    total_data double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ranks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ranks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ranks_id_seq OWNED BY ranks.id;


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE referrals (
    id integer NOT NULL,
    user_id integer,
    referral_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE referrals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE referrals_id_seq OWNED BY referrals.id;


--
-- Name: ride_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ride_types (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ride_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ride_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ride_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ride_types_id_seq OWNED BY ride_types.id;


--
-- Name: riding_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE riding_groups (
    id integer NOT NULL,
    title character varying,
    leader_id integer,
    riders integer[] DEFAULT '{}'::integer[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: riding_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE riding_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: riding_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE riding_groups_id_seq OWNED BY riding_groups.id;


--
-- Name: riding_preferences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE riding_preferences (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: riding_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE riding_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: riding_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE riding_preferences_id_seq OWNED BY riding_preferences.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles_users (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_users_id_seq OWNED BY roles_users.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE routes (
    id integer NOT NULL,
    title character varying,
    difficulty character varying,
    rating double precision,
    elevation character varying,
    ridedate date,
    description text,
    privacy_id integer,
    condition_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data text,
    user_id integer,
    surface_id integer,
    ride_distance integer,
    ride_time integer,
    completed boolean DEFAULT false,
    ride_type_id integer,
    encoded_path character varying(4096),
    is_readonly boolean DEFAULT false,
    archived boolean DEFAULT false NOT NULL,
    latitude numeric(9,6),
    longitude numeric(9,6),
    max_lean integer,
    cached_votes_total integer DEFAULT 0,
    cached_votes_score integer DEFAULT 0,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    cached_weighted_score integer DEFAULT 0,
    cached_weighted_total integer DEFAULT 0,
    cached_weighted_average double precision DEFAULT 0.0,
    average_speed real,
    max_speed real
);


--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE routes_id_seq OWNED BY routes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shared_rides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shared_rides (
    id integer NOT NULL,
    route_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    new boolean
);


--
-- Name: shared_rides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shared_rides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shared_rides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shared_rides_id_seq OWNED BY shared_rides.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    transaction_id integer,
    premium_plan_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    card_expires_at date,
    email_sent boolean,
    coupon_id integer,
    canceled_at timestamp without time zone
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;


--
-- Name: surfaces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE surfaces (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: surfaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE surfaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surfaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE surfaces_id_seq OWNED BY surfaces.id;


--
-- Name: user_bikes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_bikes (
    id integer NOT NULL,
    user_id integer,
    model character varying,
    type_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_bikes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_bikes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_bikes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_bikes_id_seq OWNED BY user_bikes.id;


--
-- Name: user_locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_locations (
    id integer NOT NULL,
    user_id integer,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_locations_id_seq OWNED BY user_locations.id;


--
-- Name: user_riding_preferences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_riding_preferences (
    id integer NOT NULL,
    user_id integer,
    preference_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_riding_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_riding_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_riding_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_riding_preferences_id_seq OWNED BY user_riding_preferences.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    firstname character varying,
    lastname character varying,
    zip character varying,
    motorcycle_club character varying,
    fb_id bigint,
    fb_token character varying,
    location character varying,
    gender character varying,
    age character varying,
    about_me text,
    riding_preference character varying,
    subscribed boolean,
    avatar_id integer,
    authentication_token character varying,
    subscription_id integer,
    fb_friends_ids integer[] DEFAULT '{}'::integer[],
    fb_fetched_at timestamp without time zone,
    latitude numeric(9,6),
    longitude numeric(9,6),
    role_id integer,
    time_zone character varying,
    device_tokens text[] DEFAULT '{}'::text[],
    fb_session_expired boolean DEFAULT false,
    app_settings hstore
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    votable_id integer,
    votable_type character varying,
    voter_id integer,
    voter_type character varying,
    vote_flag boolean,
    vote_scope character varying,
    vote_weight integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY affiliates ALTER COLUMN id SET DEFAULT nextval('affiliates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY announcements ALTER COLUMN id SET DEFAULT nextval('announcements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY card_transactions ALTER COLUMN id SET DEFAULT nextval('card_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY challenges ALTER COLUMN id SET DEFAULT nextval('challenges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY club_riding_preferences ALTER COLUMN id SET DEFAULT nextval('club_riding_preferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY club_types ALTER COLUMN id SET DEFAULT nextval('club_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clubs ALTER COLUMN id SET DEFAULT nextval('clubs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions ALTER COLUMN id SET DEFAULT nextval('conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY coupons ALTER COLUMN id SET DEFAULT nextval('coupons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendships ALTER COLUMN id SET DEFAULT nextval('friendships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY galleries ALTER COLUMN id SET DEFAULT nextval('galleries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY galleries_attachments ALTER COLUMN id SET DEFAULT nextval('galleries_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_rides ALTER COLUMN id SET DEFAULT nextval('group_rides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites ALTER COLUMN id SET DEFAULT nextval('invites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY premium_plans ALTER COLUMN id SET DEFAULT nextval('premium_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY privacies ALTER COLUMN id SET DEFAULT nextval('privacies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks ALTER COLUMN id SET DEFAULT nextval('ranks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY referrals ALTER COLUMN id SET DEFAULT nextval('referrals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ride_types ALTER COLUMN id SET DEFAULT nextval('ride_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY riding_groups ALTER COLUMN id SET DEFAULT nextval('riding_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY riding_preferences ALTER COLUMN id SET DEFAULT nextval('riding_preferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles_users ALTER COLUMN id SET DEFAULT nextval('roles_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY routes ALTER COLUMN id SET DEFAULT nextval('routes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shared_rides ALTER COLUMN id SET DEFAULT nextval('shared_rides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY surfaces ALTER COLUMN id SET DEFAULT nextval('surfaces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_bikes ALTER COLUMN id SET DEFAULT nextval('user_bikes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_locations ALTER COLUMN id SET DEFAULT nextval('user_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_riding_preferences ALTER COLUMN id SET DEFAULT nextval('user_riding_preferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: affiliates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY affiliates
    ADD CONSTRAINT affiliates_pkey PRIMARY KEY (id);


--
-- Name: announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: card_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY card_transactions
    ADD CONSTRAINT card_transactions_pkey PRIMARY KEY (id);


--
-- Name: challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY challenges
    ADD CONSTRAINT challenges_pkey PRIMARY KEY (id);


--
-- Name: club_riding_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY club_riding_preferences
    ADD CONSTRAINT club_riding_preferences_pkey PRIMARY KEY (id);


--
-- Name: club_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY club_types
    ADD CONSTRAINT club_types_pkey PRIMARY KEY (id);


--
-- Name: clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (id);


--
-- Name: friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: galleries_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY galleries_attachments
    ADD CONSTRAINT galleries_attachments_pkey PRIMARY KEY (id);


--
-- Name: galleries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY galleries
    ADD CONSTRAINT galleries_pkey PRIMARY KEY (id);


--
-- Name: group_rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_rides
    ADD CONSTRAINT group_rides_pkey PRIMARY KEY (id);


--
-- Name: invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: premium_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY premium_plans
    ADD CONSTRAINT premium_plans_pkey PRIMARY KEY (id);


--
-- Name: privacies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY privacies
    ADD CONSTRAINT privacies_pkey PRIMARY KEY (id);


--
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: referrals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY referrals
    ADD CONSTRAINT referrals_pkey PRIMARY KEY (id);


--
-- Name: ride_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ride_types
    ADD CONSTRAINT ride_types_pkey PRIMARY KEY (id);


--
-- Name: riding_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY riding_groups
    ADD CONSTRAINT riding_groups_pkey PRIMARY KEY (id);


--
-- Name: riding_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY riding_preferences
    ADD CONSTRAINT riding_preferences_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles_users
    ADD CONSTRAINT roles_users_pkey PRIMARY KEY (id);


--
-- Name: routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: shared_rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shared_rides
    ADD CONSTRAINT shared_rides_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: surfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY surfaces
    ADD CONSTRAINT surfaces_pkey PRIMARY KEY (id);


--
-- Name: user_bikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_bikes
    ADD CONSTRAINT user_bikes_pkey PRIMARY KEY (id);


--
-- Name: user_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_locations
    ADD CONSTRAINT user_locations_pkey PRIMARY KEY (id);


--
-- Name: user_riding_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_riding_preferences
    ADD CONSTRAINT user_riding_preferences_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: index_activities_on_follower_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_follower_id ON activities USING btree (follower_id);


--
-- Name: index_activities_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_user_id ON activities USING btree (user_id);


--
-- Name: index_affiliates_on_club_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_affiliates_on_club_id ON affiliates USING btree (club_id);


--
-- Name: index_affiliates_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_affiliates_on_user_id ON affiliates USING btree (user_id);


--
-- Name: index_announcements_on_club_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_announcements_on_club_id ON announcements USING btree (club_id);


--
-- Name: index_attachments_on_gallery_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_gallery_id ON attachments USING btree (gallery_id);


--
-- Name: index_clubs_on_club_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_clubs_on_club_type_id ON clubs USING btree (club_type_id);


--
-- Name: index_clubs_on_privacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_clubs_on_privacy_id ON clubs USING btree (privacy_id);


--
-- Name: index_comments_on_related_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_related_id ON comments USING btree (related_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_galleries_attachments_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_galleries_attachments_on_attachment_id ON galleries_attachments USING btree (attachment_id);


--
-- Name: index_galleries_attachments_on_gallery_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_galleries_attachments_on_gallery_id ON galleries_attachments USING btree (gallery_id);


--
-- Name: index_galleries_on_route_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_galleries_on_route_id ON galleries USING btree (route_id);


--
-- Name: index_group_rides_on_club_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_rides_on_club_id ON group_rides USING btree (club_id);


--
-- Name: index_group_rides_on_route_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_group_rides_on_route_id ON group_rides USING btree (route_id);


--
-- Name: index_members_on_club_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_club_id ON members USING btree (club_id);


--
-- Name: index_members_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_user_id ON members USING btree (user_id);


--
-- Name: index_on_routes_location; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_routes_location ON routes USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_on_users_location; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_users_location ON users USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_on_users_locations_location; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_users_locations_location ON user_locations USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_premium_plans_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_premium_plans_on_role_id ON premium_plans USING btree (role_id);


--
-- Name: index_ranks_on_challenge_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ranks_on_challenge_id_and_user_id ON ranks USING btree (challenge_id, user_id);


--
-- Name: index_ranks_on_user_id_and_challenge_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ranks_on_user_id_and_challenge_id ON ranks USING btree (user_id, challenge_id);


--
-- Name: index_roles_users_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_users_on_role_id ON roles_users USING btree (role_id);


--
-- Name: index_roles_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_users_on_user_id ON roles_users USING btree (user_id);


--
-- Name: index_routes_on_cached_votes_down; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_votes_down ON routes USING btree (cached_votes_down);


--
-- Name: index_routes_on_cached_votes_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_votes_score ON routes USING btree (cached_votes_score);


--
-- Name: index_routes_on_cached_votes_total; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_votes_total ON routes USING btree (cached_votes_total);


--
-- Name: index_routes_on_cached_votes_up; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_votes_up ON routes USING btree (cached_votes_up);


--
-- Name: index_routes_on_cached_weighted_average; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_weighted_average ON routes USING btree (cached_weighted_average);


--
-- Name: index_routes_on_cached_weighted_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_weighted_score ON routes USING btree (cached_weighted_score);


--
-- Name: index_routes_on_cached_weighted_total; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_cached_weighted_total ON routes USING btree (cached_weighted_total);


--
-- Name: index_routes_on_condition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_condition_id ON routes USING btree (condition_id);


--
-- Name: index_routes_on_privacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_privacy_id ON routes USING btree (privacy_id);


--
-- Name: index_routes_on_ride_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_ride_type_id ON routes USING btree (ride_type_id);


--
-- Name: index_routes_on_surface_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_surface_id ON routes USING btree (surface_id);


--
-- Name: index_routes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_routes_on_user_id ON routes USING btree (user_id);


--
-- Name: index_user_bikes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_bikes_on_user_id ON user_bikes USING btree (user_id);


--
-- Name: index_user_locations_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_locations_on_updated_at ON user_locations USING btree (updated_at);


--
-- Name: index_user_locations_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_locations_on_user_id ON user_locations USING btree (user_id);


--
-- Name: index_users_on_avatar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_avatar_id ON users USING btree (avatar_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_c60fcb2fce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_locations
    ADD CONSTRAINT fk_rails_c60fcb2fce FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130912071016');

INSERT INTO schema_migrations (version) VALUES ('20130917085914');

INSERT INTO schema_migrations (version) VALUES ('20130918084135');

INSERT INTO schema_migrations (version) VALUES ('20131015030437');

INSERT INTO schema_migrations (version) VALUES ('20131015074614');

INSERT INTO schema_migrations (version) VALUES ('20131021084351');

INSERT INTO schema_migrations (version) VALUES ('20131021084413');

INSERT INTO schema_migrations (version) VALUES ('20131021084521');

INSERT INTO schema_migrations (version) VALUES ('20131021092540');

INSERT INTO schema_migrations (version) VALUES ('20131023072845');

INSERT INTO schema_migrations (version) VALUES ('20131108094122');

INSERT INTO schema_migrations (version) VALUES ('20131118080219');

INSERT INTO schema_migrations (version) VALUES ('20131120081152');

INSERT INTO schema_migrations (version) VALUES ('20131120081250');

INSERT INTO schema_migrations (version) VALUES ('20131120083549');

INSERT INTO schema_migrations (version) VALUES ('20131122074540');

INSERT INTO schema_migrations (version) VALUES ('20131126073605');

INSERT INTO schema_migrations (version) VALUES ('20131205111446');

INSERT INTO schema_migrations (version) VALUES ('20131209075520');

INSERT INTO schema_migrations (version) VALUES ('20131216073955');

INSERT INTO schema_migrations (version) VALUES ('20140120100321');

INSERT INTO schema_migrations (version) VALUES ('20140120101029');

INSERT INTO schema_migrations (version) VALUES ('20140120104026');

INSERT INTO schema_migrations (version) VALUES ('20140123102630');

INSERT INTO schema_migrations (version) VALUES ('20140124045211');

INSERT INTO schema_migrations (version) VALUES ('20140127092901');

INSERT INTO schema_migrations (version) VALUES ('20140131094222');

INSERT INTO schema_migrations (version) VALUES ('20140131102656');

INSERT INTO schema_migrations (version) VALUES ('20140131104226');

INSERT INTO schema_migrations (version) VALUES ('20140203095445');

INSERT INTO schema_migrations (version) VALUES ('20140204082138');

INSERT INTO schema_migrations (version) VALUES ('20140204082818');

INSERT INTO schema_migrations (version) VALUES ('20140211062112');

INSERT INTO schema_migrations (version) VALUES ('20140213095140');

INSERT INTO schema_migrations (version) VALUES ('20140213101351');

INSERT INTO schema_migrations (version) VALUES ('20140217062701');

INSERT INTO schema_migrations (version) VALUES ('20140217084553');

INSERT INTO schema_migrations (version) VALUES ('20140218091239');

INSERT INTO schema_migrations (version) VALUES ('20140220112346');

INSERT INTO schema_migrations (version) VALUES ('20140227093450');

INSERT INTO schema_migrations (version) VALUES ('20140228094718');

INSERT INTO schema_migrations (version) VALUES ('20140307045907');

INSERT INTO schema_migrations (version) VALUES ('20140309171210');

INSERT INTO schema_migrations (version) VALUES ('20140311162729');

INSERT INTO schema_migrations (version) VALUES ('20140326071440');

INSERT INTO schema_migrations (version) VALUES ('20140326074132');

INSERT INTO schema_migrations (version) VALUES ('20140326075424');

INSERT INTO schema_migrations (version) VALUES ('20140326075517');

INSERT INTO schema_migrations (version) VALUES ('20140329201836');

INSERT INTO schema_migrations (version) VALUES ('20140329202347');

INSERT INTO schema_migrations (version) VALUES ('20140330112046');

INSERT INTO schema_migrations (version) VALUES ('20140330153536');

INSERT INTO schema_migrations (version) VALUES ('20140330162150');

INSERT INTO schema_migrations (version) VALUES ('20140330200831');

INSERT INTO schema_migrations (version) VALUES ('20140402074520');

INSERT INTO schema_migrations (version) VALUES ('20140402173655');

INSERT INTO schema_migrations (version) VALUES ('20140404193917');

INSERT INTO schema_migrations (version) VALUES ('20140417080515');

INSERT INTO schema_migrations (version) VALUES ('20140417080641');

INSERT INTO schema_migrations (version) VALUES ('20140428104004');

INSERT INTO schema_migrations (version) VALUES ('20140519082248');

INSERT INTO schema_migrations (version) VALUES ('20140519112931');

INSERT INTO schema_migrations (version) VALUES ('20140519124502');

INSERT INTO schema_migrations (version) VALUES ('20140521141954');

INSERT INTO schema_migrations (version) VALUES ('20140609072704');

INSERT INTO schema_migrations (version) VALUES ('20140609091827');

INSERT INTO schema_migrations (version) VALUES ('20140623133502');

INSERT INTO schema_migrations (version) VALUES ('20140623183928');

INSERT INTO schema_migrations (version) VALUES ('20140702115721');

INSERT INTO schema_migrations (version) VALUES ('20140714151641');

INSERT INTO schema_migrations (version) VALUES ('20140727193642');

INSERT INTO schema_migrations (version) VALUES ('20140727195730');

INSERT INTO schema_migrations (version) VALUES ('20140730124240');

INSERT INTO schema_migrations (version) VALUES ('20140804090619');

INSERT INTO schema_migrations (version) VALUES ('20140804103324');

INSERT INTO schema_migrations (version) VALUES ('20140819084913');

INSERT INTO schema_migrations (version) VALUES ('20140822064519');

INSERT INTO schema_migrations (version) VALUES ('20140823130624');

INSERT INTO schema_migrations (version) VALUES ('20140824125741');

INSERT INTO schema_migrations (version) VALUES ('20140824140755');

INSERT INTO schema_migrations (version) VALUES ('20140824141002');

INSERT INTO schema_migrations (version) VALUES ('20140824185201');

INSERT INTO schema_migrations (version) VALUES ('20140831065259');

INSERT INTO schema_migrations (version) VALUES ('20140902190543');

INSERT INTO schema_migrations (version) VALUES ('20140905132451');

INSERT INTO schema_migrations (version) VALUES ('20141005150100');

INSERT INTO schema_migrations (version) VALUES ('20150105193607');

INSERT INTO schema_migrations (version) VALUES ('20150111143406');

INSERT INTO schema_migrations (version) VALUES ('20150202195548');

INSERT INTO schema_migrations (version) VALUES ('20150220160113');

INSERT INTO schema_migrations (version) VALUES ('20150220180908');

INSERT INTO schema_migrations (version) VALUES ('20150220190537');

INSERT INTO schema_migrations (version) VALUES ('20150226130418');

INSERT INTO schema_migrations (version) VALUES ('20150226131008');

INSERT INTO schema_migrations (version) VALUES ('20150226192800');

INSERT INTO schema_migrations (version) VALUES ('20150303103402');

INSERT INTO schema_migrations (version) VALUES ('20150303184555');

INSERT INTO schema_migrations (version) VALUES ('20150303204246');

INSERT INTO schema_migrations (version) VALUES ('20150306003915');

INSERT INTO schema_migrations (version) VALUES ('20150309204432');

INSERT INTO schema_migrations (version) VALUES ('20150314091742');

