// cart/cubit/cart_cubit.dart ou blocs/cart/cart_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart'; // Pour firstWhereOrNull
import 'package:hungerz/models/cart_item_model.dart';
import 'package:hungerz/models/menu_item_model.dart';
// Assurez-vous d'importer Dish
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  // La liste interne des items, privée au Cubit
  final List<CartItem> _items = [];

  // Initialiser le Cubit avec l'état CartInitial
  CartCubit() : super(CartInitial()) {
     // Optionnel: émettre immédiatement un état 'updated' vide si vous préférez
     // _emitCartUpdated();
  }

  // Méthode pour ajouter un plat au panier
  void addItem(MenuItemModel dish) {
    // Cherche si un item avec le même Dish existe déjà
    final existingItem = _items.firstWhereOrNull((item) => item.dish.id == dish.id);

    if (existingItem != null) {
      // Si oui, incrémente juste la quantité
      existingItem.quantity++;
    } else {
      // Si non, crée un nouvel CartItem et l'ajoute à la liste
      _items.add(CartItem(dish: dish, quantity: 1));
    }
    // Émet le nouvel état mis à jour
    _emitCartUpdated();
  }

  // Méthode pour retirer complètement un article (basé sur l'ID du plat)
  void removeItem(String dishId) {
    _items.removeWhere((item) => item.dish.id == dishId);
    _emitCartUpdated();
  }

  // Méthode pour incrémenter la quantité d'un article existant
  void incrementItem(String dishId) {
    final item = _items.firstWhereOrNull((item) => item.dish.id == dishId);
    if (item != null) {
      item.quantity++;
      _emitCartUpdated();
    }
  }

  // Méthode pour décrémenter la quantité (et retirer si elle atteint 0)
  void decrementItem(String dishId) {
    final item = _items.firstWhereOrNull((item) => item.dish.id == dishId);
    if (item != null) {
      item.quantity--;
      if (item.quantity <= 0) {
        // Si la quantité est 0 ou moins, retire l'item
        _items.remove(item);
      }
      _emitCartUpdated();
    }
  }

  // Méthode pour vider complètement le panier
  void clearCart() {
    _items.clear();
    _emitCartUpdated();
  }

  // Méthode privée pour calculer le total et émettre l'état CartUpdated
  void _emitCartUpdated() {
    final double totalPrice = _calculateTotalPrice();
    // Émet une copie de la liste pour assurer la détection du changement d'état
    emit(CartUpdated(items: List.from(_items), totalPrice: totalPrice));
  }

  // Méthode privée pour calculer le prix total du panier
  double _calculateTotalPrice() {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
    // Alternative:
    // double total = 0.0;
    // for (var item in _items) {
    //   total += item.dish.price * item.quantity;
    // }
    // return total;
  }
}