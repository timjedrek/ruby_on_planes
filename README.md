# Ruby on Planes

This is a [Right Rudder Marketing](https://rightruddermarketing.com) (RRM) project to code named "Ruby on Planes," a public-facing flight school directory web application built with Ruby on Rails and initialized by [Tim Jedrek](https://github.com/timjedrek) starting April 2, 2025. The goal is to connect aspiring pilots with top-tier flight schools across the United States, making it simple to find training options by state, city, airport, or nearby towns. 

Beyond just a listings site, this app’s got user ratings and comments to help pilots pick the best schools, admin controls to keep the data legit, and a hardcore focus on SEO to dominate search results for terms like "flight schools near me" or "pilot training in Missouri." 

We’re leveraging server-rendered views with Tailwind CSS for modern, responsive design, Hotwire for real-time updates like butter points on comments, and a PostgreSQL database to handle the heavy lifting. Check out more of what we do at [Right Rudder Marketing on GitHub](https://github.com/right-rudder).  If you want to contribute, get in contact with us.

## Models and Relationships

Below is the summary of models and their relationships.

### 1. User (via Devise)
- **Purpose**: Represents anyone interacting with the app—think student pilots browsing schools, instructors linking their profiles, or RRM admins managing content. Uses Devise for email/password authentication with confirmation, ensuring only verified users can rate, comment, or claim school associations. The `admin` flag unlocks a dashboard to approve submissions and tweak listings.
- **Fields**:
  - Devise defaults: `email:string`, `encrypted_password:string`, `confirmation_token:string`, etc.
  - `admin:boolean` (default: false) - Flags admin users.
- **Relationships**:
  - `has_many :ratings, dependent: :destroy`
  - `has_many :comments, dependent: :destroy`
  - `has_many :user_schools, dependent: :destroy`
  - `has_many :schools, through: :user_schools`

### 2. State
- **Purpose**: Holds all 50 US states to power SEO-friendly pages like `/states/MO` that list every airport and school in Missouri. It’s the top of the location hierarchy, ensuring we can rank for broad searches like "flight schools in California" while keeping airport data tied to a consistent state list—no typos or duplicates allowed.
- **Fields**:
  - `name:string` (required) - e.g., "Missouri"
  - `abbreviation:string` (required, unique) - e.g., "MO"
- **Relationships**:
  - `has_many :airports, dependent: :restrict_with_error` - One state has many airports.

### 3. Airport
- **Purpose**: Maps out every airport where flight schools operate, like "STL" for St. Louis Lambert, with `nearby_towns` to snag searches like "flight schools near Chesterfield." It’s the glue between states and schools, letting us build pages like `/airports/STL` and tie schools to real-world locations for users and search engines alike.
- **Fields**:
  - `code:string` (required) - e.g., "STL"
  - `name:string` (required) - e.g., "St. Louis Lambert International Airport"
  - `city:string` (required) - e.g., "St. Louis"
  - `nearby_towns:string[]` (array, default: []) - e.g., ["Chesterfield", "Ballwin"]
  - `state_id:references` - Foreign key to `states`
- **Relationships**:
  - `belongs_to :state` - Each airport is in one state.
  - `has_many :schools, dependent: :restrict_with_error`

### 4. School
- **Purpose**: The star of the show—flight schools like "RRM Flight School" with all the details: plane counts, instructor numbers, training types, and certifications (Part 141/61). It’s where users come to read ratings, comments, and contact info, and where the top schools get a `featured` boost. The `approved` flag lets admins vet user-submitted schools before they go live.
- **Fields**:
  - `name:string` (required)
  - `description:text` (optional)
  - `est_planes:integer`
  - `est_cfis:integer`
  - `part_141:boolean` (default: false)
  - `part_61:boolean` (default: false)
  - `training_types:string[]` (array, default: [])
  - `accelerated_programs:boolean` (default: false)
  - `examining_authority:boolean` (default: false)
  - `date_established:date`
  - `featured:boolean` (default: false)
  - `approved:boolean` (default: false)
  - `airport_id:references`
- **Relationships**:
  - `belongs_to :airport`
  - `has_many :contact_people, dependent: :destroy`
  - `has_many :ratings, dependent: :destroy`
  - `has_many :comments, dependent: :destroy`
  - `has_many :user_schools, dependent: :destroy`
  - `has_many :users, through: :user_schools`

### 5. ContactPerson
- **Purpose**: Lists key people at each school—owners, CFIs, whoever’s running the show — with contact details. It’s the human connection on school pages, letting users reach out directly while giving admins a way to manage who’s listed.
- **Fields**:
  - `name:string` (required)
  - `role:string` (required)
  - `email:string` (required)
  - `phone:string` (optional)
  - `school_id:references`
- **Relationships**:
  - `belongs_to :school`

### 6. Rating
- **Purpose**: Lets verified users give a 1-5 star rating on schools, feeding into average ratings displayed on school pages. It’s instant feedback that helps pilots pick winners and gives schools a rep boost (or a reality check), all published right away for max transparency.
- **Fields**:
  - `user_id:references`
  - `school_id:references`
  - `rating:integer` (required, 1-5)
- **Relationships**:
  - `belongs_to :user`
  - `belongs_to :school`

### 7. Comment
- **Purpose**: Where verified users drop their thoughts on schools—could be praise, critiques, or replies to others in threaded discussions. The `approved` flag keeps it clean (pending admin review), while `butter_points` let anyone upvote good takes, making it a lively community hub tied to each school.
- **Fields**:
  - `user_id:references`
  - `school_id:references`
  - `content:text` (required)
  - `approved:boolean` (default: false)
  - `butter_points:integer` (default: 0)
  - `parent_id:references` (self-referential)
- **Relationships**:
  - `belongs_to :user`
  - `belongs_to :school`
  - `belongs_to :parent, class_name: "Comment", optional: true`
  - `has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy`
  - `has_many :butter_points_logs, dependent: :destroy`

### 8. ButterPointsLog
- **Purpose**: Tracks every "butter point" (upvote) on comments to stop spammers from juicing the count. By logging session IDs, it ensures one vote per visitor per comment, keeping the system fair and the hot comments legit.
- **Fields**:
  - `comment_id:references`
  - `session_id:string` (required)
  - `created_at:datetime`
- **Relationships**:
  - `belongs_to :comment`

### 9. UserSchool
- **Purpose**: Links users (like instructors or owners) to schools for their profiles, letting them claim an association that admins approve. It’s how we show "Jane Doe teaches at RRM Flight School" on both her profile and the school page, building trust and credibility.
- **Fields**:
  - `user_id:references`
  - `school_id:references`
  - `approved:boolean` (default: false)
- **Relationships**:
  - `belongs_to :user`
  - `belongs_to :school`