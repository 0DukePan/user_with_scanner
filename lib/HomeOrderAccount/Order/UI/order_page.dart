// lib/HomeOrderAccount/Order/UI/order_page.dart

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hungerz/Locale/locales.dart';
import 'package:hungerz/Pages/order_detail_page.dart';
import 'package:hungerz/Pages/reservation_detail_page.dart'; // Pour la navigation des réservations
// --- AJOUTS POUR LES COMMANDES ---
import 'package:hungerz/cubits/order_cubit/order_cubit.dart';
import 'package:hungerz/models/order_details_model.dart'; // Utilisé dans OrderDetailsModel
// TODO: Créez et importez OrderDetailsPage pour la navigation des commandes
// import 'package:hungerz/Pages/order_details_page.dart';
// ----------------------------------
import 'package:hungerz/Themes/colors.dart';
import 'package:hungerz/cubits/reservation_cubit/reservation_cubit.dart';
import 'package:hungerz/models/reservation_model.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    // Charger l'historique des réservations
    print(
        "OrderPage (Réservations Tab): initState - Appel de fetchMyReservations.");
    context.read<ReservationCubit>().fetchMyReservations();

    // --- AJOUT : Charger l'historique des commandes ---
    print("OrderPage (Commandes Tab): initState - Appel de fetchOrderHistory.");
    context.read<OrderCubit>().fetchOrderHistory();
    // ------------------------------------------------
  }

  // --- Méthode pour rafraîchir les réservations (existante) ---
  Future<void> _refreshReservations() async {
    print(
        "OrderPage (Réservations Tab): Pull-to-refresh - Appel de fetchMyReservations.");
    await context.read<ReservationCubit>().fetchMyReservations();
  }

  // --- AJOUT : Méthode pour rafraîchir les commandes ---
  Future<void> _refreshOrders() async {
    print(
        "OrderPage (Commandes Tab): Pull-to-refresh - Appel de fetchOrderHistory.");
    await context.read<OrderCubit>().fetchOrderHistory();
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                indicatorColor: kMainColor,
                labelColor: kMainColor,
                unselectedLabelColor: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7) ??
                    Colors.grey,
                indicatorWeight: 3.0,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 15),
                tabs: [
                  Tab(
                    text: locale.orderText!, // "COMMANDES"
                  ),
                  Tab(
                    text: locale.tabletext!, // "RÉSERVATIONS"
                  )
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            // --- Onglet 1: Historique des COMMANDES (Logique réelle) ---
            _buildOrdersHistoryTab(context, locale),

            // --- Onglet 2: Historique des RÉSERVATIONS (Logique existante, inchangée) ---
            BlocBuilder<ReservationCubit, ReservationState>(
              builder: (context, state) {
                if (state is ReservationInitial ||
                    (state is ReservationHistoryLoading)) {
                  // Modifié pour correspondre à votre code fourni
                  return Center(
                      child: CircularProgressIndicator(color: kMainColor));
                } else if (state is ReservationHistoryError) {
                  // Modifié
                  return _buildReservationErrorState(
                      context, state.message); // Renommé pour clarté
                } else if (state is ReservationHistoryLoaded) {
                  // Modifié
                  List<ReservationModel> currentReservations =
                      state.reservations;
                  if (currentReservations.isEmpty) {
                    return _buildReservationEmptyState(
                        context); // Renommé pour clarté
                  }
                  return RefreshIndicator(
                    onRefresh: _refreshReservations,
                    color: kMainColor,
                    backgroundColor: Colors.white,
                    child: _buildReservationsList(
                        context, locale, currentReservations, state),
                  );
                }
                return Center(
                    child: Text("État de réservation inattendu.",
                        style: TextStyle(color: Colors.orange)));
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- AJOUT : Widget principal pour l'onglet de l'historique des commandes ---
  Widget _buildOrdersHistoryTab(BuildContext context, AppLocalizations locale) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderInitial ||
            (state is OrderHistoryLoading &&
                (state.props.isEmpty ||
                    (state.props.isNotEmpty &&
                        (state.props.first as List<OrderDetailsModel>?)
                                ?.isEmpty ==
                            true)))) {
          // Afficher le loader si état initial ou chargement sans données existantes
          return Center(child: CircularProgressIndicator(color: kMainColor));
        } else if (state is OrderHistoryError &&
            (state.props.isEmpty ||
                (state.props.isNotEmpty &&
                    (state.props.first as List<OrderDetailsModel>?)?.isEmpty ==
                        true))) {
          // Afficher l'erreur si pas de données existantes
          return _buildOrderErrorState(context, state.message);
        } else if (state is OrderHistoryLoaded ||
            (state is OrderHistoryLoading &&
                state.props.isNotEmpty &&
                (state.props.first as List<OrderDetailsModel>?)?.isNotEmpty ==
                    true) ||
            (state is OrderHistoryError &&
                state.props.isNotEmpty &&
                (state.props.first as List<OrderDetailsModel>?)?.isNotEmpty ==
                    true)) {
          List<OrderDetailsModel> currentOrders = [];
          if (state is OrderHistoryLoaded) {
            currentOrders = state.orders;
          } else if (state is OrderHistoryLoading && state.props.isNotEmpty) {
            // Tentative de récupérer les commandes existantes de l'état précédent si possible
            // Ceci est une simplification; un état de chargement avec données serait mieux.
            // Pour l'instant, on suppose que props[0] sont les commandes si elles existent.
            try {
              currentOrders =
                  List<OrderDetailsModel>.from(state.props.first as List);
            } catch (_) {/* Ignorer si le cast échoue */}
          } else if (state is OrderHistoryError && state.props.isNotEmpty) {
            try {
              currentOrders =
                  List<OrderDetailsModel>.from(state.props.first as List);
            } catch (_) {/* Ignorer */}
          }

          if (currentOrders.isEmpty && state is OrderHistoryLoaded) {
            return _buildOrderEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            color: kMainColor,
            backgroundColor: Colors.white,
            child: _buildOrdersList(context, locale, currentOrders, state),
          );
        }
        return Center(
            child: Text("État de commande inattendu.",
                style: TextStyle(color: Colors.orange)));
      },
    );
  }

  // --- AJOUT : Widget pour construire la liste des commandes ---
  Widget _buildOrdersList(BuildContext context, AppLocalizations locale,
      List<OrderDetailsModel> orders, OrderState currentState) {
    // Trier les commandes: en cours (pending, confirmed, preparing, out_for_delivery) en premier, puis passées.
    List<OrderDetailsModel> ongoingOrders = orders
        .where((o) => ["pending", "confirmed", "preparing", "out_for_delivery"]
            .contains(o.status.toLowerCase()))
        .toList();
    List<OrderDetailsModel> pastOrders = orders
        .where(
            (o) => ["delivered", "cancelled"].contains(o.status.toLowerCase()))
        .toList();

    // Trier chaque section par date (plus récent en premier)
    ongoingOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    pastOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (orders.isEmpty && currentState is OrderHistoryLoaded) {
      // Double vérification pour l'état vide
      return _buildOrderEmptyState(context);
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        if (currentState is OrderHistoryLoading && orders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: CircularProgressIndicator(
                    color: kMainColor, strokeWidth: 2.5)),
          ),
        if (currentState is OrderHistoryError && orders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: Text(
                    "Erreur de rafraîchissement: ${currentState.message}",
                    style: TextStyle(color: Colors.orange[700]))),
          ),
        if (ongoingOrders.isNotEmpty) ...[
          _buildSectionTitle(context, "Commandes en cours"), // Utiliser locale
          ...ongoingOrders
              .map((order) => _buildOrderCard(context, locale, order, true))
              .toList(),
          SizedBox(height: 20),
        ],
        if (pastOrders.isNotEmpty) ...[
          _buildSectionTitle(context, "Commandes passées"), // Utiliser locale
          ...pastOrders
              .map((order) => _buildOrderCard(context, locale, order, false))
              .toList(),
        ],
        if (orders.isEmpty &&
            currentState
                is! OrderHistoryLoading) // Si la liste globale est vide après chargement
          _buildOrderEmptyState(context),
      ],
    );
  }

  // --- AJOUT : Widget pour afficher une carte de commande ---
  Widget _buildOrderCard(BuildContext context, AppLocalizations locale,
      OrderDetailsModel order, bool isOngoing) {
    // Tente de trouver un nom de restaurant à partir du premier article.
    // C'est une simplification. Idéalement, OrderDetailsModel aurait une info restaurant.
    // "Votre Commande"
    String? firstItemImage;

    if (order.items.isNotEmpty) {
      // Si vos OrderItemModel ont un champ restaurantName ou si vous pouvez l'inférer
      // restaurantName = order.items.first.restaurantName ?? restaurantName;
      // Pour l'image, si OrderItemModel a un champ 'image'
      firstItemImage = order.items[0].image;
    }

    return Card(
      color: Colors.white,
      elevation: isOngoing ? 3.0 : 1.5,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Rendre onTap async
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: order),
            ),
          );
          // Si OrderDetailsPage a pop avec true (indiquant que les notes ont été soumises)
          if (mounted) {
            // Vérifier aussi si le widget est monté
            print(
                "Retour de OrderDetailsPage avec succès de notation, rafraîchissement de l'historique des commandes.");
            _refreshOrders(); // Appeler la méthode de rafraîchissement
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Image de l'article ou du restaurant
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: FadedScaleAnimation(
                      // Animation
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: firstItemImage != null &&
                                firstItemImage.isNotEmpty
                            ? Image.network(
                                firstItemImage, // Assurez-vous que l'URL est complète et valide
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[200],
                                        child: Icon(Icons.fastfood_outlined,
                                            color: Colors.grey[400], size: 30)),
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                child: Icon(Icons.receipt_long_outlined,
                                    color: Colors.grey[400], size: 30)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Pour l'instant, nous n'avons pas le nom du restaurant directement sur OrderDetailsModel
                          // Affichons le type de commande ou un titre générique
                          "Commande #${order.id.substring(0, 6)}... (${order.orderType})", // Ex: "Commande #123abc... (Delivery)"
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM yyyy, HH:mm',
                                  locale.locale.languageCode)
                              .format(order.createdAt
                                  .toLocal()), // Date de la commande
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.grey[600], fontSize: 13),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "${order.total.toStringAsFixed(2)} ${'DA'}", // Total de la commande
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      kMainColor, // Mettre le total en couleur principale
                                  fontSize: 15),
                        )
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      _getOrderStatusText(
                          context, order.status), // Traduire le statut
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Taille de police du chip
                          fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: _getOrderStatusColor(order.status),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  )
                ],
              ),
              if (order.items.isNotEmpty) ...[
                Divider(height: 24, thickness: 0.8, color: Colors.grey[200]),
                Text(
                  "${'Articles'}: ${order.items.length}", // "Articles: 3"
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                SizedBox(height: 6),
                // Afficher les 2-3 premiers articles
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 1.0, bottom: 1.0),
                      child: Text(
                        "• ${item.quantity}x ${item.name}",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 13.0, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                    child: Text(
                      "et ${order.items.length - 2} autre(s)...",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic),
                    ),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- AJOUT : Helper pour la couleur du statut de la commande ---
  Color _getOrderStatusColor(String status) {
    status = status.toLowerCase();
    switch (status) {
      case 'pending':
        return Colors.orange.shade400;
      case 'confirmed':
        return Colors.blue.shade400;
      case 'preparing':
        return Colors.deepPurple.shade300;
      case 'out_for_delivery':
        return Colors.teal.shade300;
      case 'delivered':
        return Colors.green.shade500;
      case 'cancelled':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  // --- AJOUT : Helper pour traduire le statut de la commande ---
  String _getOrderStatusText(BuildContext context, String status) {
    var locale = AppLocalizations.of(context)!;
    status = status.toLowerCase();
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'out_for_delivery':
        return 'En livraison';
      case 'delivered':
        return locale.delivered ?? 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  // --- AJOUT : Widget pour l'état vide des commandes ---
  Widget _buildOrderEmptyState(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("Aucune commande pour le moment.", // Utiliser locale
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[600])),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text("Rafraîchir",
                        style:
                            TextStyle(color: Colors.white)), // Utiliser locale
                    onPressed: _refreshOrders,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // --- AJOUT : Widget pour l'état d'erreur des commandes ---
  Widget _buildOrderErrorState(BuildContext context, String message) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text("Oops! Une erreur est survenue.", // Utiliser locale
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.red[700])),
                  SizedBox(height: 8),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[400])),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text("Réessayer",
                        style:
                            TextStyle(color: Colors.white)), // Utiliser locale
                    onPressed: _refreshOrders,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // --- Widgets pour les réservations (existants et légèrement renommés pour clarté) ---
  Widget _buildReservationEmptyState(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_outlined,
                      size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("Aucune réservation pour le moment.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[600])),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text("Rafraîchir",
                        style: TextStyle(color: Colors.white)),
                    onPressed: _refreshReservations,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReservationErrorState(BuildContext context, String message) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text("Oops! Une erreur est survenue.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.red[700])),
                  SizedBox(height: 8),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[400])),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text("Réessayer",
                        style: TextStyle(color: Colors.white)),
                    onPressed: _refreshReservations,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReservationsList(BuildContext context, AppLocalizations locale,
      List<ReservationModel> reservations, ReservationState currentState) {
    final now = DateTime.now();
    List<ReservationModel> upcomingReservations = [];
    List<ReservationModel> pastReservations = [];

    for (var reservation in reservations) {
      bool isConsideredPast =
          reservation.reservationTime.add(Duration(hours: 2)).isBefore(now);
      bool isStatusPast = reservation.status == 'completed' ||
          reservation.status == 'cancelled' ||
          reservation.status == 'no-show';

      if (isConsideredPast || isStatusPast) {
        pastReservations.add(reservation);
      } else {
        upcomingReservations.add(reservation);
      }
    }

    upcomingReservations
        .sort((a, b) => a.reservationTime.compareTo(b.reservationTime));
    pastReservations
        .sort((a, b) => b.reservationTime.compareTo(a.reservationTime));

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        if (currentState is ReservationHistoryLoading &&
            reservations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: CircularProgressIndicator(
                    color: kMainColor, strokeWidth: 2.5)),
          ),
        if (currentState is ReservationHistoryError && reservations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: Text(
                    "${"Erreur de rafraîchissement"}: ${currentState.message}", // Utiliser locale
                    style: TextStyle(color: Colors.orange[700]))),
          ),

        if (upcomingReservations.isNotEmpty) ...[
          _buildSectionTitle(
              context, "Réservations à venir/en cours"), // Utiliser locale
          ...upcomingReservations
              .map((res) => _buildReservationCard(context, res, locale, true))
              .toList(),
          SizedBox(height: 20),
        ],
        if (pastReservations.isNotEmpty) ...[
          _buildSectionTitle(
              context, "Réservations passées"), // Utiliser locale
          ...pastReservations
              .map((res) => _buildReservationCard(context, res, locale, false))
              .toList(),
        ],
        if (reservations.isEmpty && currentState is! ReservationHistoryLoading)
          _buildReservationEmptyState(
              context), // Afficher si la liste globale est vide
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    // (Inchangé, déjà bon)
    return Padding(
      padding:
          const EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 12.0),
      child: Text(title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 18)),
    );
  }

  Widget _buildReservationCard(BuildContext context,
      ReservationModel reservation, AppLocalizations locale, bool isUpcoming) {
    // (Inchangé, déjà bon - juste une petite correction sur le nom du restaurant)
    Color cardColor = isUpcoming ? Colors.white : Colors.grey[50]!;
    double elevation = isUpcoming ? 3.0 : 1.0;

    return Card(
      elevation: elevation,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ReservationDetailPage(reservation: reservation)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(
                          "Dine-in", // Utiliser le nom du restaurant si disponible
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isUpcoming ? kMainColor : Colors.black87,
                                  fontSize: 17),
                          overflow: TextOverflow.ellipsis)),
                  Chip(
                    label: Text(
                        _getReservationStatusText(context,
                            reservation.status), // Utiliser locale pour statut
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    backgroundColor: _getReservationStatusColor(
                        reservation.status, isUpcoming), // Renommé
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildDetailRow(
                  context,
                  Icons.calendar_today_outlined,
                  DateFormat('EEE, d MMM yyyy',
                          locale.locale.languageCode) // Format de date ajusté
                      .format(reservation.reservationTime.toLocal())),
              SizedBox(height: 4),
              _buildDetailRow(
                  context,
                  Icons.access_time_outlined,
                  DateFormat('HH:mm', locale.locale.languageCode)
                      .format(reservation.reservationTime.toLocal())),
              SizedBox(height: 4),
              _buildDetailRow(context, Icons.people_alt_outlined,
                  "${reservation.guests} ${reservation.guests > 1 ? ('personnes') : ('personne')}"),
              if (reservation.preselectedItems != null &&
                  reservation.preselectedItems!.isNotEmpty) ...[
                SizedBox(height: 10),
                _buildExpansionDetail(
                  context: context,
                  title: "Pré-commande", // Utiliser locale
                  icon: Icons.shopping_bag_outlined,
                  children: reservation.preselectedItems!
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 2.0, bottom: 2.0),
                            child: Text(
                                "• ${item['quantity']}x ${item['menuItemNameFromData'] ?? item['name'] ?? ('Article inconnu')}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[700])),
                          ))
                      .toList(),
                ),
              ],
              if (reservation.specialRequests != null &&
                  reservation.specialRequests!.isNotEmpty) ...[
                SizedBox(height: 10),
                _buildExpansionDetail(
                    context: context,
                    title: "Demandes spéciales", // Utiliser locale
                    icon: Icons.notes_outlined,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 2.0, bottom: 2.0),
                        child: Text(reservation.specialRequests!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[700])),
                      )
                    ]),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionDetail(
      {required BuildContext context,
      required String title,
      required IconData icon,
      required List<Widget> children}) {
    // (Inchangé, déjà bon)
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20, color: Colors.grey[600]),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: Colors.black54)),
        childrenPadding: EdgeInsets.only(left: 16, bottom: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    // (Inchangé, déjà bon)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14.5, color: Colors.black87))),
      ]),
    );
  }

  // Renommé pour clarté, spécifique aux réservations
  Color _getReservationStatusColor(String status, bool isUpcoming) {
    // (Inchangé, déjà bon)
    status = status.toLowerCase();
    if (isUpcoming && status == 'confirmed') {
      return kMainColor.withOpacity(0.8);
    }
    switch (status) {
      case 'confirmed':
        return Colors.green.shade500;
      case 'pending':
        return Colors.orange.shade500;
      case 'completed':
        return Colors.blue.shade500;
      case 'cancelled':
        return Colors.red.shade400;
      case 'no-show':
        return Colors.grey.shade500;
      default:
        return Colors.grey.shade400;
    }
  }

  // Helper pour traduire le statut de la réservation
  String _getReservationStatusText(BuildContext context, String status) {
    status = status.toLowerCase();
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      case 'no-show':
        return 'Non présenté';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  // --- Section des commandes factices (sera remplacée) ---
  // Widget _buildDummyOrdersTab(BuildContext context, AppLocalizations locale) {
  //   return Center(child: Text("Logique des commandes à implémenter ici."));
  // }
  // Widget _buildDummyOrderCard(...) { /* ... */ }
}

// // import 'package:animation_wrappers/Animations/faded_scale_animation.dart';
// import 'package:animation_wrappers/animation_wrappers.dart';
// import 'package:flutter/material.dart';
// import 'package:hungerz/HomeOrderAccount/Home/UI/order_placed_map.dart';
// import 'package:hungerz/Locale/locales.dart';
// import 'package:hungerz/Routes/routes.dart';
// import 'package:hungerz/Themes/colors.dart';
// import 'package:hungerz/Themes/style.dart';

// class OrderPage extends StatelessWidget {
//   const OrderPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           flexibleSpace: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TabBar(
//                 indicatorColor: Colors.transparent,
//                 labelColor: Color(0xff000000),
//                 unselectedLabelColor: Color(0xffc4c8c1),
//                 tabs: [
//                   Tab(
//                     child: Text(
//                       AppLocalizations.of(context)!.orderText!,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.3,
//                       ),
//                     ),
//                   ),
//                   Tab(
//                     child: Text(AppLocalizations.of(context)!.tabletext!,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.3,
//                         )),
//                   )
//                 ],
//               ),
//             ],
//           ),
//           automaticallyImplyLeading: false,
//         ),
//         body: CustomScrollView(
//           physics: BouncingScrollPhysics(),
//           slivers: <Widget>[
//             SliverFillRemaining(
//               child: TabBarView(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => OrderMapPage(),
//                       ),
//                     ),
//                     child: ListView(
//                       children: <Widget>[
//                         SizedBox(
//                           height: 15,
//                         ),
//                         Container(
//                           height: 51.0,
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           color: Theme.of(context).cardColor,
//                           child: Text(
//                             AppLocalizations.of(context)!.process!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge!
//                                 .copyWith(
//                                     color: Color(0xff99a596),
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.67),
//                           ),
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 1.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.store!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Text(
//                                   'Delivery | 20 Jun, 11:35',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleLarge!
//                                       .copyWith(
//                                           fontSize: 11.7,
//                                           color: Color(0xffc1c1c1)),
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.pickup!,
//                                       style: orderMapAppBarTextStyle.copyWith(
//                                           color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '\$ 21.00 | ${AppLocalizations.of(context)!.paypal}',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 1.0,
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 80.0),
//                           child: Text(
//                             '${AppLocalizations.of(context)!.sandwich}  x1',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall!
//                                 .copyWith(fontSize: 12.0, letterSpacing: 0.05),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 80.0, vertical: 5.0),
//                           child: Text(
//                             '${AppLocalizations.of(context)!.chicken}  x1',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall!
//                                 .copyWith(fontSize: 12.0, letterSpacing: 0.05),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 80.0),
//                           child: Text(
//                             '${AppLocalizations.of(context)!.juice}  x1',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall!
//                                 .copyWith(fontSize: 12.0, letterSpacing: 0.05),
//                           ),
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 2.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.storee!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Text(
//                                   'Take Away | 11:35 min',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleLarge!
//                                       .copyWith(
//                                           fontSize: 11.7,
//                                           color: Color(0xffc1c1c1)),
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       "Ready to Pickup",
//                                       style: orderMapAppBarTextStyle.copyWith(
//                                           color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '\$ 21.00 | ${AppLocalizations.of(context)!.paypal}',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 1.0,
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 80.0),
//                           child: Text(
//                             '${AppLocalizations.of(context)!.sandwich}  x1',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall!
//                                 .copyWith(fontSize: 12.0, letterSpacing: 0.05),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 80.0),
//                           child: Text(
//                             '${AppLocalizations.of(context)!.juice}  x1',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall!
//                                 .copyWith(fontSize: 12.0, letterSpacing: 0.05),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8.0,
//                         ),
//                         Container(
//                           height: 51.0,
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           color: Theme.of(context).cardColor,
//                           child: Text(
//                             AppLocalizations.of(context)!.past!.toUpperCase(),
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge!
//                                 .copyWith(
//                                     color: Color(0xff99a596),
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.67),
//                           ),
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/layer5.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.seven!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Text(
//                                   'Delivery | 20 June, 11:35am',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleLarge!
//                                       .copyWith(
//                                           fontSize: 11.7,
//                                           color: Color(0xffc1c1c1)),
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.deliv!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '\$ 18.00 | ${AppLocalizations.of(context)!.credit}',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 1.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsetsDirectional.only(start: 80.0),
//                               child: Text(
//                                 '${AppLocalizations.of(context)!.sandwich}  x1',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall!
//                                     .copyWith(
//                                         fontSize: 12.0, letterSpacing: 0.05),
//                               ),
//                             ),
//                             Spacer(),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: InkWell(
//                                 onTap: () => Navigator.pushNamed(
//                                     context, PageRoutes.rate),
//                                 child: Text(
//                                   AppLocalizations.of(context)!.rate!,
//                                   style: orderMapAppBarTextStyle.copyWith(
//                                       color: Theme.of(context).primaryColor),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 80.0, vertical: 5.0),
//                           child: Text(
//                             '${AppLocalizations.of(context)!.chicken}  x1',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall!
//                                 .copyWith(fontSize: 12.0, letterSpacing: 0.05),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 5.0,
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 1,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 3.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.jesica!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Text(
//                                   'Dine in | 20 June, 11:35am',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleLarge!
//                                       .copyWith(
//                                           fontSize: 11.7,
//                                           color: Color(0xffc1c1c1)),
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.deliv!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '\$ 8.00 | ${AppLocalizations.of(context)!.credit}',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 1.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsetsDirectional.only(start: 80.0),
//                               child: Text(
//                                 '${AppLocalizations.of(context)!.sandwich}  x1',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall!
//                                     .copyWith(
//                                         fontSize: 12.0, letterSpacing: 0.05),
//                               ),
//                             ),
//                             Spacer(),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 10.0),
//                               child: InkWell(
//                                 // onTap: () => Navigator.pushNamed(
//                                 //     context, PageRoutes.rate),
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       "Rated ★ 5.0 ",
//                                       style: orderMapAppBarTextStyle.copyWith(
//                                           fontSize: 12),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 5.0,
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 1,
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => OrderMapPage(),
//                       ),
//                     ),
//                     child: ListView(
//                       children: <Widget>[
//                         SizedBox(
//                           height: 15,
//                         ),
//                         Container(
//                           height: 51.0,
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           color: Theme.of(context).cardColor,
//                           child: Text(
//                             AppLocalizations.of(context)!.upcomming!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge!
//                                 .copyWith(
//                                     color: Color(0xff99a596),
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.67),
//                           ),
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 1.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.store!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.cancel!,
//                                       style: orderMapAppBarTextStyle.copyWith(
//                                           color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '2 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 2.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.storee!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.cancel!,
//                                       style: orderMapAppBarTextStyle.copyWith(
//                                           color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '3 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         SizedBox(
//                           height: 8.0,
//                         ),
//                         Container(
//                           height: 51.0,
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           color: Theme.of(context).cardColor,
//                           child: Text(
//                             AppLocalizations.of(context)!.pastt!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge!
//                                 .copyWith(
//                                     color: Color(0xff99a596),
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.67),
//                           ),
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/layer5.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.seven!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.rebook!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '2 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 3.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.jesica!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.rebook!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '2 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 1.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.store!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.rebook!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '4 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 3.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.jesica!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.rebook!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '3 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/Layer 2.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.storee!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.rebook!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '2 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                         Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.only(left: 20.0),
//                               child: FadedScaleAnimation(
//                                 fadeDuration: Duration(milliseconds: 200),
//                                 child: Image.asset(
//                                   'images/Restaurants/layer5.png',
//                                   scale: 6,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   AppLocalizations.of(context)!.seven!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       'Booking for ',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Color(0xffc1c1c1)),
//                                     ),
//                                     Text(
//                                       '20 Jun, 11:30 am',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               color: Colors.black),
//                                     )
//                                   ],
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     Text(
//                                       AppLocalizations.of(context)!.rebook!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: kMainColor),
//                                     ),
//                                     SizedBox(height: 7.0),
//                                     Text(
//                                       '3 Persons',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleLarge!
//                                           .copyWith(
//                                               fontSize: 11.7,
//                                               letterSpacing: 0.06,
//                                               color: Color(0xffc1c1c1)),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         Divider(
//                           color: Theme.of(context).cardColor,
//                           thickness: 8.0,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
