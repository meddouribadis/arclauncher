/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:math';

import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/category.dart';

export 'package:flauncher/models/app.dart';
export 'package:flauncher/models/category.dart';


@GenerateNiceMocks([
  MockSpec<FLauncherChannel>(),
  MockSpec<WallpaperService>(),
  MockSpec<AppsService>(),
  MockSpec<SettingsService>(),
  MockSpec<WatchNextService>(),
  MockSpec<ImagePicker>(),
  MockSpec<FLauncherDatabase>(unsupportedMembers: {#alias}),
  MockSpec<ImageProvider>(unsupportedMembers: {#alias}),
])
void main() {}

App fakeApp({
  String packageName = "me.efesser.flauncher",
  String name = "FLauncher",
  String version = "1.0.0",
  bool hidden = false,
  bool sideloaded = false,
}) {
    final app = App(
      packageName: packageName,
      name: name,
      version: version,
      hidden: hidden,
    );
    app.sideloaded = sideloaded;
    return app;
}

class CategoryWithApps extends Category {
  CategoryWithApps(Category category, List<App> applications)
      : super.withApplications(
          name: category.name,
          id: category.id,
          order: category.order,
          sort: category.sort,
          type: category.type,
          rowHeight: category.rowHeight,
          columnsCount: category.columnsCount,
          applications: applications,
        );

  Category get category => this;
  Category get _category => this;
}

Category fakeCategory({
  String name = "Favorites",
  int id = 0,
  int order = 0,
  CategorySort sort = CategorySort.manual,
  CategoryType type = CategoryType.grid,
  int rowHeight = 110,
  int columnsCount = 6,
  List<App> applications = const [],
}) =>
    Category.withApplications(
      id: id == 0 ? Random().nextInt(1 << 30) + 1 : id,
      name: name,
      sort: sort,
      type: type,
      rowHeight: rowHeight,
      columnsCount: columnsCount,
      order: order,
      applications: applications,
    );
