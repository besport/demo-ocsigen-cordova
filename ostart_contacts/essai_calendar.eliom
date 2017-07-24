(* Calendar demo *)

[%%shared
  open Eliom_content.Html
  open Eliom_content.Html.F
]

(* Service for this demo, defined in the server-side app *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["essai_calendar"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu. This value is defined both server and client-side. *)
let%shared name () = [%i18n S.essai_calendar]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-essai-calendar"



(*a given types definition *)

[%%client


  type eventid = int64
  type userid = int64
  type clubid = int64
  type wallid = int64
  type spotid = int64
  type sportid = int64
  type photo_info =
    { photo_name : string; width : int; height : int; s3 : bool } [@@deriving json]

  type blockid = int64


  module Event_date = struct
    type t = {
      startdate : CalendarLib.Calendar.t;
      enddate : CalendarLib.Calendar.t;
      allday : bool;
      multitimeslot : bool;
      recurringdate : CalendarLib.Calendar.t option;
    }
  end


  type event =
    { eventid : eventid;
      authorid : userid option;
      clubid: clubid option ;
      title : string;
      public : bool;
      open_participation : bool;
      invitees_can_invite : bool;
      coverposition : float;
      picture : photo_info;
      wallid : wallid;
      sports : sportid list;
      clubs : (clubid * string * bool) list;
      creationdate : CalendarLib.Calendar.t;
      date : Event_date.t;
      description : string option;
      minp : int64 option;
      maxp : int64 option;
      parentevent: eventid option;
      location: string; (*(spotid option * location) option;*********first suggested location*****)
      result : string option;
      ancestors : (string * eventid) list;
      (* First is direct parent, last is root *)
      weight: float;
      reminder: int64 option;
      live: bool ;
      blockid : blockid
    }



]

(* function that adds a new event with default parameters you can interactively change*)
let%shared add_event () =

  let _ : unit Eliom_client_value.t =
    [%client

      if Essai_contacts.is_client_app () then
        begin
        (*instantiation of an event*)
        let photoInfo = {photo_name = "nice picture"; width = 30; height = 30; s3 = true} in
        let sportIdList = [Int64.one;Int64.one;Int64.one;Int64.one] in
        let myClubs = [(Int64.one,"Hayasa",true);(Int64.one,"GMT",true)] in
        let eventDate = {Event_date.startdate = CalendarLib.Calendar.now ();enddate = CalendarLib.Calendar.now (); allday = true; multitimeslot = true; recurringdate = Some (CalendarLib.Calendar.now ()) } in
        let myDescription = Some "default description" in
        let myMinp = Some Int64.one in
        let myMaxp = Some Int64.one in
        let parentEvent = Some Int64.one in
        let myResult = Some "result" in
        let myAncestors = [("ancestor1",Int64.one);("ancestor2",Int64.one)] in
        let myReminder = Some Int64.one in

        let ev = {eventid = Int64.one ;authorid =Some Int64.one;clubid=Some Int64.one;title="default title";public=true;open_participation=true;invitees_can_invite=true;picture=photoInfo;coverposition=3.0;wallid=Int64.one;sports=sportIdList;clubs=myClubs;
                  creationdate=CalendarLib.Calendar.now (); date=eventDate; description=myDescription; minp=myMinp; maxp=myMaxp; parentevent=parentEvent; location="Besport's office"; result=myResult; ancestors=myAncestors; weight=40.0; reminder=myReminder; live=true; blockid=Int64.one}

        in
              (*the function to convert a besport event into an Android calendar event*)
        let besport_to_agenda eventid title open_participation (creationdate:CalendarLib.Calendar.t) (date:Event_date.t) description location reminder =

          let notes = ref "" in
          let year = string_of_int (CalendarLib.Calendar.year creationdate) in
          let month = CalendarLib.Calendar.month creationdate in
          let myMonth =

            match month with
            | 	Jan -> "1"
            | 	Feb -> "2"
            | 	Mar -> "3"
            | 	Apr -> "4"
            | 	May -> "5"
            | 	Jun -> "6"
            | 	Jul -> "7"
            | 	Aug -> "8"
            | 	Sep -> "9"
            | 	Oct -> "10"
            | 	Nov -> "11"
            | 	Dec -> "12"
          in

          let day = string_of_int (CalendarLib.Calendar.day_of_month creationdate) in
          notes := !notes ^ "-This event was created the " ^ myMonth ^ "/" ^ day ^ "/" ^ year ^ ".\n" ;
          notes := !notes ^ "-";

          let myDescription =
            match description with
            |Some x ->  x
            |_ -> ""
          in

          notes := !notes ^ myDescription;

          let url = "https://www.besport.com/event/" ^ (Int64.to_string eventid) in

          let success_function msg = Eliom_lib.alert "%s%!" "createEventWithOptions is a Success"
          in
          let error_function msg =  Eliom_lib.alert "%s%!" "createEventWithOptions is a Failure"
          in

          let year2 = CalendarLib.Calendar.year date.startdate in
          let day2 = CalendarLib.Calendar.day_of_month date.startdate in
          let month2 = CalendarLib.Calendar.month date.startdate in
          let myMonth2 =

            match month2 with
            | 	Jan -> 1
            | 	Feb -> 2
            | 	Mar -> 3
            | 	Apr -> 4
            | 	May -> 5
            | 	Jun -> 6
            | 	Jul -> 7
            | 	Aug -> 8
            | 	Sep -> 9
            | 	Oct -> 10
            | 	Nov -> 11
            | 	Dec -> 12
          in

          let startDate =  Js_date.create ~year:year2 ~month:myMonth2 ~day:day2 () in
          let year3 = CalendarLib.Calendar.year date.enddate in
          let day3 = CalendarLib.Calendar.day_of_month date.enddate in
          let month3 = CalendarLib.Calendar.month date.enddate in
          let myMonth3 =

            match month3 with
            | 	Jan -> 1
            | 	Feb -> 2
            | 	Mar -> 3
            | 	Apr -> 4
            | 	May -> 5
            | 	Jun -> 6
            | 	Jul -> 7
            | 	Aug -> 8
            | 	Sep -> 9
            | 	Oct -> 10
            | 	Nov -> 11
            | 	Dec -> 12
          in

          let endDate =  Js_date.create ~year:year3 ~month:myMonth3 ~day:day3 () in

          let myReminder = match reminder with
            |Some x -> Int64.to_int x
            | _     ->  0
          in
          let myOptions = Cordova_calendar.create_options ~first_reminder_minutes:myReminder ~url:url () in

          Cordova_calendar.createEventInteractivelyWithOptions ~title:title ~location:location ~notes:!notes ~start_date:startDate ~end_date:endDate ~cal_options:myOptions success_function error_function

        in
        besport_to_agenda ev.eventid ev.title ev.open_participation ev.creationdate ev.date ev.description ev.location ev.reminder;
      end else
        begin
          Eliom_lib.alert "You can't export an event: you need to use the mobile application!"
        end

    ] in
  Lwt.return ()




let%shared button msg f =
  let btn =
    Eliom_content.Html.
      (D.button ~a:[D.a_class ["button"]] [D.pcdata msg])
  in
  ignore [%client
    ((Lwt.async @@ fun () ->
      Lwt_js_events.clicks
        (Eliom_content.Html.To_dom.of_element ~%btn)
        (fun _ _ -> ~%f ()))
     : unit)
  ];
  btn

(* Page for this demo *)
let%shared page () =


  let btn =
    button [%i18n S.essai_calendar_click]
      [%client
        ((fun () ->
           add_event ();
           Lwt.return ())
         : unit -> unit Lwt.t)
      ]
  in


  Lwt.return Eliom_content.Html.[
    F.h1 [%i18n essai_calendar_button]
  ; F.p [F.pcdata [%i18n S.only_works_on_smartphone]]
  ; F.p [F.pcdata [%i18n S.essai_calendar_button_description]]
  ; F.p [btn]
  ]
