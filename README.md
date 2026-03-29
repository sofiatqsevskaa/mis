# Cafe Web Application with Event Management

## Overview

This project is a full-stack web application for a cafe / third space. It provides an event management system and it allows users to view scheduled activities.

The system is designed to run in a browser (chrome) and is also supported on macOS environments.

The application consists of:

- A JavaScript-based backend
- A Flutter frontend that provides a responsive and interactive user interface

## Features

### Main Page

The landing page presents the cafe in a visually engaging way. It includes:

- A general introduction to the cafe
- Highlighted or upcoming events
- Key information such as location and availability

### Event System

The core functionality of the application revolves around events.

Users can:

- View a list of all available events
- Access detailed information for each event
- See event schedules and availability

Each event includes:

- Title and description
- Date and time
- Additional metadata relevant to the event

### Booking System

Users can book events directly through the application.

The booking flow includes:

- Selecting an event
- Choosing an available time slot
- Confirming the booking

The system ensures:

- Only valid and available slots can be booked
- Only whitelisted users can request events (insures that a random user won't spam)

### Calendar Integration

A calendar view allows users to:

- Navigate events by date
- Get a clear overview of upcoming activities
- Easily identify available and booked days

### Administrator Comment Threads

Each event has an associated comment thread intended for administrators, used for:

- Internal communication between admins
- Discussion and coordination related to specific events

Comments are:

- Linked to individual events
- Persisted and retrievable

### Map Integration

The application includes a map to help users locate the cafe.

Users can:

- View the cafe location visually
- Understand nearby context
- Google maps is integrated to help the user get to the venue

## Architecture

The project is divided into two main parts:

### Backend (JavaScript)

The backend handles:

- API endpoints
- Event and booking logic
- Data storage and retrieval

We use PostgreSQL.

### Frontend (Flutter)

The frontend is responsible for:

- Rendering the UI
- Handling user interactions
- Communicating with the backend via API calls

It is designed to run in:

- Web browsers (Chrome)
- macOS environments

## Future Improvements

- Improved mobile responsiveness
- Expanded admin tools
