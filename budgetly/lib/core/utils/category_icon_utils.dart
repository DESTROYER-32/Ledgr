import 'package:flutter/material.dart';

IconData materialCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'work':
      return Icons.work;
    case 'code':
      return Icons.code;
    case 'trending_up':
      return Icons.trending_up;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'home':
      return Icons.home;
    case 'bolt':
      return Icons.bolt;
    case 'directions_car':
      return Icons.directions_car;
    case 'restaurant':
      return Icons.restaurant;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'movie':
      return Icons.movie;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'subscriptions':
      return Icons.subscriptions;
    case 'security':
      return Icons.security;
    case 'school':
      return Icons.school;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'attach_money':
      return Icons.attach_money;
    case 'money_off':
      return Icons.money_off;
    default:
      return Icons.category;
  }
}
