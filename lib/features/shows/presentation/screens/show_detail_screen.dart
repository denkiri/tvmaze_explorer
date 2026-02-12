import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvmaze_explorer/core/utils/html_utils.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/favorites_provider.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_providers.dart';
import 'package:tvmaze_explorer/features/shows/presentation/widgets/cast_card.dart';
import 'package:tvmaze_explorer/features/shows/presentation/widgets/error_state_widget.dart';

// Detail screen displaying comprehensive information about a TV show.
class ShowDetailScreen extends ConsumerWidget {
  const ShowDetailScreen({
    super.key,
    required this.showId,
    required this.showName,
  });

  final int showId;
  final String showName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAsync = ref.watch(showDetailProvider(showId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: showAsync.when(
        loading: () => _buildLoadingState(context),
        error: (error, _) => _buildErrorState(context, ref, error.toString()),
        data: (show) => _buildContent(context, ref, show, colorScheme),
      ),
    );
  }

  /// Loading state with app bar and centered spinner.
  Widget _buildLoadingState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(showName),
          pinned: true,
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  // Error state with retry button — uses shared ErrorStateWidget inside a
  // SliverAppBar layout so the back button is still accessible.
  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(showName),
          pinned: true,
        ),
        SliverFillRemaining(
          child: ErrorStateWidget(
            message: error,
            icon: Icons.error_outline_rounded,
            onRetry: () => ref.invalidate(showDetailProvider(showId)),
          ),
        ),
      ],
    );
  }

  // Main content with show details and cast.
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Show show,
    ColorScheme colorScheme,
  ) {
    final isFavorite = ref.watch(
      favoritesProvider.select((s) => s.isFavorite(show.id)),
    );

    return CustomScrollView(
      slivers: [
        //  Hero poster in SliverAppBar
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              show.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
            background: show.imageOriginal != null
                ? CachedNetworkImage(
                    imageUrl: show.imageOriginal!,
                    fit: BoxFit.cover,
                    placeholder: (_, progress) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, error, widget) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.tv,
                        size: 80,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.tv,
                      size: 80,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          actions: [
            // Favorite button in app bar.
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : null,
              ),
              onPressed: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(show.id);
              },
            ),
          ],
        ),

        // Details body
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Rating ──
                if (show.rating != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        show.rating!.toStringAsFixed(1),
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        ' / 10',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Genres
                if (show.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: show.genres
                        .map(
                          (genre) => Chip(
                            label: Text(genre),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Summary ──
                if (show.summary != null &&
                    show.summary!.isNotEmpty) ...[
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    HtmlUtils.stripHtml(show.summary),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Info cards
                _buildInfoSection(context, colorScheme, show),
                const SizedBox(height: 24),

                // ── Cast section ──
                if (show.cast.isNotEmpty) ...[
                  Text(
                    'Cast',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: show.cast.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          CastCard(castMember: show.cast[index]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  //Builds the info section with status, premiere, schedule, and network.
  Widget _buildInfoSection(
    BuildContext context,
    ColorScheme colorScheme,
    Show show,
  ) {
    final infoItems = <_InfoItem>[];

    if (show.status != null) {
      infoItems.add(_InfoItem(
        icon: Icons.info_outline_rounded,
        label: 'Status',
        value: show.status!,
      ));
    }

    if (show.premiered != null) {
      infoItems.add(_InfoItem(
        icon: Icons.calendar_today_rounded,
        label: 'Premiered',
        value: show.premiered!,
      ));
    }

    if (show.scheduleDays.isNotEmpty || show.scheduleTime != null) {
      final schedule = [
        if (show.scheduleDays.isNotEmpty) show.scheduleDays.join(', '),
        if (show.scheduleTime != null && show.scheduleTime!.isNotEmpty)
          'at ${show.scheduleTime}',
      ].join(' ');
      if (schedule.isNotEmpty) {
        infoItems.add(_InfoItem(
          icon: Icons.schedule_rounded,
          label: 'Schedule',
          value: schedule,
        ));
      }
    }

    final platform = show.networkName ?? show.webChannelName;
    if (platform != null) {
      infoItems.add(_InfoItem(
        icon: Icons.live_tv_rounded,
        label: 'Network',
        value: platform,
      ));
    }

    if (infoItems.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: infoItems.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == infoItems.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: colorScheme.primary, size: 22),
                title: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                subtitle: Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                dense: true,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

//data class for info section items.
class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
