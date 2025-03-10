import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/etablissement.dart';
import 'package:sav_app/models/familly.dart';
import 'package:sav_app/models/filtred_catalog.dart';
import 'package:sav_app/models/filtred_client.dart';
import 'package:sav_app/models/filtred_commands_client.dart';
import 'package:sav_app/models/filtred_opportunity.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/models/sfamilly.dart';
import 'package:sav_app/models/user.dart';

class AppUrl {
  // static String baseUrlApi = 'http://"+AppUrl.user.company!+".my-crm.net:5188/api/';
  // static String baseUrl = 'http://"+AppUrl.user.company!+".my-crm.net:5188/';
  static String baseUrlApi = '';
  static String baseUrl = '';
  static List<Etablissement> etabList = [];

  static List<Familly> tierFamillies = [];
  static List<SFamilly> tierSFamillies = [];

  static List<Familly> villes = [];
  static List<SFamilly> allQuartiers = [];

  static List<Familly> tierRegions = [];
  static List<SFamilly> tierSectors = [];

  static FiltredClient filtredClient = FiltredClient();

  static Color lighten(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);

    return Color.fromARGB(
      color.alpha,
      (color.red + ((255 - color.red) * factor)).round(),
      (color.green + ((255 - color.green) * factor)).round(),
      (color.blue + ((255 - color.blue) * factor)).round(),
    );
  }

  static double getFullWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
  static double getFullHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  static int nbNotif = 0;
  static int syncroTime = 30;
  static int dayDepasAct = -1;
  static int dayDepasCoursAct = -1;
  static DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0);
  static DateTime endTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0, 0);
  static String projetLotsConcurrents = baseUrlApi + 'ProjetLotConcurrents';// post/put
  static String contacts = baseUrlApi + 'Contacts/origin/'; //{idClient}
  static String getTiersConcurrents = baseUrlApi + 'TiersConcurrents'; // /
  static String tierFamilly =
      baseUrlApi + 'TiersFams';
  static String tierSFamilly =
      baseUrlApi + 'TiersSFams';
  static String getVilles =
      baseUrlApi + 'Villes';
  static String tierRegion =
      baseUrlApi + 'Regions';
  static String tierSector =
      baseUrlApi + 'Secteurs';
  static String getQuartiers =
      baseUrlApi + 'Quartiers';
  static String editAddress = baseUrlApi + 'Adress'; // get {famillyId} /api/Adress/{id}
  static String getRegion = baseUrlApi + 'Regions/'; // get {famillyId}
  static String getSecteur = baseUrlApi + 'Secteur/'; // get {famillyId}
  static String contact = baseUrlApi + 'Contacts';
  static String getCivilte = baseUrlApi + 'Tables?type=CIV'; //get
  static String tier = baseUrlApi + 'Tier'; //{id}
  static String getStartEnd = baseUrlApi + 'Societes';
  static String getSociete = baseUrlApi + 'Societes';
  static String auth = baseUrlApi + 'Auth/Authenticate';
  static String getUser = baseUrlApi + 'Users/one/'; //{id}
  static String getRoles = baseUrlApi + 'Roles/one/'; //{id}
  static String getEquipes = baseUrlApi + 'Equipes/children/'; //{idEquipe}
  static String getCollaborateur = baseUrlApi + 'Equipes/Users/'; //{id}
  static String getContacts = baseUrlApi + 'Contacts/origin/'; //{id}
  static String tounee = baseUrlApi + 'Pipeline/1'; //{id}
  static String getPipelines = baseUrlApi + 'Pipeline'; //get
  static String devisOfOpportunite =
      baseUrlApi + 'Devis/'; // {etbCode}/{oppoCode}
  static String getPipelinesSteps =
      baseUrlApi + 'Pipeline/Etapes/'; // {idPip} get
  static String getTeamsPipeline = baseUrlApi + 'Pipeline/equipes/'; // get {id}
  static String opportunities = baseUrlApi + 'Opportunites';
  static String getActionTypes =
      baseUrlApi + 'TypeAction'; // get
  // send email
  static String email = baseUrlApi + 'Emails/html/'; // post {etbCode}/{docNum}
  static String getNotif = baseUrlApi + 'Notifs'; // get
  static String editNotif = baseUrlApi + 'Notifs/'; // put
  static String devis = baseUrlApi + 'Devis'; // post,
  ///api/Opportunites/filtred
  ///
  //static String getNotesOpp = baseUrlApi + 'Notes/byOpportuniteId/';// / {idOpp} get
  // my commands
  static String editCcommand = baseUrlApi + 'Commandes/'; // {id}/{etbCode}
  static String editDevis = baseUrlApi + 'Devis/'; // {id}/{etbCode}
  static String devisToCommand = baseUrlApi + 'Commandes/transfert/'; // {etbCode} post
  static String getMyCommands =
      baseUrlApi + 'Commandes/CommandeSalarie/'; // etbCode/salCode // get
  static String getMyDevis =
      baseUrlApi + 'Devis/devisSalarie/'; // etbCode/salCode // get
  static String getMyDelivred =
      baseUrlApi + 'Livraisons/bySalarie/'; // etbCode/salCode // get
  static String getMotif = baseUrlApi + 'Tables?type=moc'; //get
  static String getOneTable = baseUrlApi + 'Tables'; //get
  static String getSymptoms = baseUrlApi + 'Tables?type=sym'; //get
  static String getNatures = baseUrlApi + 'Tables?type=INT'; //get
  static String getDiagnostic = baseUrlApi + 'Tables?type=DIA'; //get
  static String getOrigin = baseUrlApi + 'Tables?type=ORI'; //get
  static String getTypeRec = baseUrlApi + 'SavReclamationsTypes'; //get
  static String getCategoriesRec = baseUrlApi + 'SavReclamationsCategories'; //get
  static String getLevels = baseUrlApi + 'Tables?type=CRI'; //get
  static String getInterTypes = baseUrlApi + 'Tables?type=TPI'; //get
  static String getInterNatures = baseUrlApi + 'Tables?type=INT'; //get
  static String getReclamationsCategories = baseUrlApi + 'SavReclamationsCategories'; //get
  static String getAllNotes = baseUrlApi + 'Notes'; // / {idOpp} post
  static String NotesOpp = baseUrlApi + 'Notes'; // post
  static String uploadFileNote = baseUrlApi + 'Notes/upload/'; // post {noteID}
  static String getFileNote = baseUrlApi + 'Notes/docNote/'; // get {noteID}
  static String opportunitiesFiltred = baseUrlApi + 'Opportunites/filtred';
  static String opportunitiesChangeState =
      baseUrlApi + 'Opportunites/Etape/'; //{id}/{etapeId}
  static String editOpportunities = baseUrlApi + 'Opportunites/'; //{idOpp} put
  static String editReclamation = baseUrlApi + 'SavDemandes/'; //{idOpp} put
  static String tiers = baseUrlApi + 'Tiers'; //{id}
  static String tiersPage = baseUrlApi + 'Tier';
  // sav
  static String reclamation = baseUrlApi + 'SavDemandes';
  static String docs = baseUrlApi + 'SavDemandeDocument';
  static String intervention = baseUrlApi + 'SavInterventions';
  //static String tiersPage = baseUrlApi + 'Tiers';
  static String tiersEcheance =
      baseUrlApi + 'Encaissements/echeancesPaged/'; // get {etb}/ pcfcode
  static String getFamilly = baseUrlApi + 'TiersFams/'; // get {famillyId}
  static String getSFamilly = baseUrlApi + 'TiersSFams/'; // get {SfamillyId}
  static String getOneTiers = baseUrlApi + 'Tiers/'; //{id} get
  static String getOneTier = baseUrlApi + 'Tier/'; //{id} get
  static String articles = baseUrlApi + 'Article';
  static String articlesSuiv = baseUrlApi + 'ArtClientSuiviSav';
  static String articlesOfFamilly =
      baseUrlApi + 'Articles/famille/'; //{idFamilly}
  static String articlesOfSFamilly =
      baseUrlApi + 'Articles/sfamille/'; //{idSFamilly}
  static String articlesFromDepot =
      baseUrlApi + 'Articles/depot/'; // {etbCode}/{depCode}
  static String articlesFromDepotPage =
      baseUrlApi + 'Articles/depotPagination/'; // {etbCode}/{depCode}
  static String getUrlImage = baseUrlApi + 'ArticleImage/article/'; // {artCode}
  static String getQuantityMax =
      baseUrlApi + 'ArtStock/article/'; // get etabliss/artCode
  static String getQuantityMaxFromDepot =
      baseUrlApi + 'ArtStock/one/'; // get etabliss/depCode/artCode
  static String getMenuAcces = baseUrlApi + 'Menu/menuAcces/'; // {roleId}
  static String getMenuAuthorized = baseUrlApi + 'Menu/authorized/'; // {roleId}
  static String getOneUser = baseUrlApi + 'Users/one/'; // {userId}
  static String getLocalDepot =
      baseUrlApi + 'Depots/salarie/'; //salCode/etablissCode
  static String depots = baseUrlApi + 'Depots/'; //{id}
  static String chargement =
      baseUrlApi + 'ChargementDechargement/chargement'; // post,
  static String dechargement =
      baseUrlApi + 'ChargementDechargement/dechargement'; // post,
  static String commands = baseUrlApi + 'Commandes'; // post,
  static String commandsOfOpportunite =
      baseUrlApi + 'Commandes/opportunite/'; // {etbCode}/{oppoCode}
  static String deliveryOfOpportunite =
      baseUrlApi + 'Livraisons/opportunite/'; // {etbCode}/{oppoCode}
  static String livraison =
      baseUrlApi + 'Livraisons/client/'; //{etbCode}/{pcfCode};
  static String livraisonsTransfert =
      baseUrlApi + 'Livraisons/transfert/'; //get;
  static String livraisons = baseUrlApi + 'Livraisons/'; //post;
  static String getOneDoc =
      baseUrlApi + 'Documents/'; // /api/Documents/{id}/{etbCode}
  static String getDocs =
      baseUrlApi + 'Documents'; //get
  static String echeances =
      baseUrlApi + 'Encaissements/echeancesPaged/'; //{etbCode}/{pcfCode}
  static String encaisser = baseUrlApi +
      'Encaissements/encaisser'; //post api/Encaissements/encaisser/{SalCode}
  static String reglement = baseUrlApi +
      'Encaissements/reglements/'; //get /api/Encaissements/reglements/{etbCode}/{pcfCode}
  static String userReglement = baseUrlApi +
      'Encaissements/reglementsPagedByUser/'; //get /api/Encaissements/reglements/{etbCode}/{salCode}
  static String retours = baseUrlApi + 'BonDeRetour/'; //post
  static String getRetours = baseUrlApi + 'BonDeRetour/etb/'; //post
  // activities
  static String getAcivitiesOpp = baseUrlApi + 'Actions/opportunite/'; //get
  static String getAcivities = baseUrlApi + 'Actions'; //get
  static String getProcess = baseUrlApi + 'Tables?type=cat'; //get
  static String getActionByProcess =
      baseUrlApi + 'TypeAction/byProcess/'; // get
  static String acivitiesOpp = baseUrlApi + 'Actions'; // post
  static String editAcivitiesOpp = baseUrlApi + 'Actions/'; // put {id}
  // itinerary
  static String itinerary = baseUrlApi + 'UserItineraires'; // get {id}
  // famille sfamille
  static String getSfamillyByFamillyID =
      baseUrlApi + 'ArticleSfaFam/getByFamille/'; // get {idFamilly}
  static String getArticlesFamilly = baseUrlApi + 'ArticlesFamille'; // get
  static User user = User();
  static FiltredOpporunity filtredOpporunity =
      FiltredOpporunity(date: DateTime.now(), dateEnd: DateTime.now());
  static FiltredOpporunity filtredRec =
  FiltredOpporunity(date: DateTime.now(), dateEnd: DateTime.now());
  static FiltredCommandsClient filtredCommandsClient =
      FiltredCommandsClient(date: DateTime.now(), dateEnd: DateTime.now());
  static FiltredCommandsClient filtredRecamationClient =
  FiltredCommandsClient(date: DateTime.now(), dateEnd: DateTime.now());
  static FiltredCatalog filtredCatalog = FiltredCatalog();
  static DateTime selectedDate = DateTime.now();
  static Client client = Client();
  static Client? selectedClient;
  static Product? selectedProduct;
  static bool changed = false;

  //static String imageUrl = '';
  static NumberFormat formatter = NumberFormat.currency(
    locale: 'fr_FR', // Use the appropriate locale for your needs
    symbol: '', // Optional: Set to the currency symbol you want to use
    decimalDigits: 2, // Number of decimal places
  );

  static bool isDateBetween(
      DateTime testDate, DateTime startDate, DateTime endDate) {
    return testDate.isAfter(startDate) && testDate.isBefore(endDate);
  }

  static var columns = [
    'Objet de la tâche',
    'Statut',
    'Tiers (Raison sociale)',
    'Type Tiers',
    'Contacts',
    'Collaborateur',
    'Date et heure début',
    'Date heure fin',
    'Catégorie',
    'Type d’activité',
    'Priorité',
    'Urgence',
    'Commantaire',
  ];

  // static var columns = [
  //   'ID',
  //   'Collaborateur',
  //   'Process',
  //   'Type d’activité',
  //   'Objet de la tâche',
  //   'Priorité',
  //   'Urgence',
  //   'Type Tiers',
  //   'Tiers (Raison sociale)',
  //   'Date début',
  //   'Heure début',
  //   'Date fin',
  //   'Heure de fin',
  //   'Alerte',
  //   'Contacts',
  //   'Statut',
  // ];
// api for get opportunities list
// /api/Etapes/opportunities/{etpId}
// list of etapes :
// /api/Etapes
//   [
//   {
//   "id": 1,
//   "libelle": "A visité",
//   "position": 1,
//   "probabilite": null,
//   "couleur": "#f56565",
//   "sommeil": false,
//   "obligatoire": true,
//   "system": true,
//   "deleted": false,
//   "dateMaj": null,
//   "dateCreate": "2023-09-03T10:11:47.6156558",
//   "dateDelete": null,
//   "userMaj": null,
//   "userCreate": "admin",
//   "userDelete": null,
//   "pipelineId": 1,
//   "pipeline": null,
//   "opportunites": null
//   },
//   {
//   "id": 2,
//   "libelle": "Visité",
//   "position": 2,
//   "probabilite": null,
//   "couleur": "#FFEB3B",
//   "sommeil": false,
//   "obligatoire": true,
//   "system": true,
//   "deleted": false,
//   "dateMaj": null,
//   "dateCreate": "2023-09-03T10:11:47.6887284",
//   "dateDelete": null,
//   "userMaj": null,
//   "userCreate": "admin",
//   "userDelete": null,
//   "pipelineId": 1,
//   "pipeline": null,
//   "opportunites": null
//   },
//   {
//   "id": 3,
//   "libelle": "Livré",
//   "position": 3,
//   "probabilite": null,
//   "couleur": "#2196F3",
//   "sommeil": false,
//   "obligatoire": true,
//   "system": true,
//   "deleted": false,
//   "dateMaj": null,
//   "dateCreate": "2023-09-03T10:11:47.6943621",
//   "dateDelete": null,
//   "userMaj": null,
//   "userCreate": "admin",
//   "userDelete": null,
//   "pipelineId": 1,
//   "pipeline": null,
//   "opportunites": null
//   },
//   {
//   "id": 4,
//   "libelle": "Encaissé",
//   "position": 4,
//   "probabilite": null,
//   "couleur": "#4CAF50",
//   "sommeil": false,
//   "obligatoire": true,
//   "system": true,
//   "deleted": false,
//   "dateMaj": null,
//   "dateCreate": "2023-09-03T10:11:47.6993241",
//   "dateDelete": null,
//   "userMaj": null,
//   "userCreate": "admin",
//   "userDelete": null,
//   "pipelineId": 1,
//   "pipeline": null,
//   "opportunites": null
//   },
//   {
//   "id": 5,
//   "libelle": "Livré & encaissé",
//   "position": 5,
//   "probabilite": null,
//   "couleur": "#0000FF",
//   "sommeil": false,
//   "obligatoire": true,
//   "system": true,
//   "deleted": false,
//   "dateMaj": null,
//   "dateCreate": "2023-09-03T10:11:47.7038816",
//   "dateDelete": null,
//   "userMaj": null,
//   "userCreate": "admin",
//   "userDelete": null,
//   "pipelineId": 1,
//   "pipeline": null,
//   "opportunites": null
//   },
//   {
//   "id": 6,
//   "libelle": "Annulée",
//   "position": 6,
//   "probabilite": null,
//   "couleur": "#2d3748",
//   "sommeil": false,
//   "obligatoire": true,
//   "system": true,
//   "deleted": false,
//   "dateMaj": null,
//   "dateCreate": "2023-09-03T10:11:47.7085623",
//   "dateDelete": null,
//   "userMaj": null,
//   "userCreate": "admin",
//   "userDelete": null,
//   "pipelineId": 1,
//   "pipeline": null,
//   "opportunites": null
//   }
//   ]
}
