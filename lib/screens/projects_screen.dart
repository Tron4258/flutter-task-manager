import 'package:flutter/material.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Project> projects = [
      Project(
        title: 'Portfolio Website',
        description: 'A personal portfolio website built with Flutter Web',
        imageUrl: 'assets/portfolio.png',
        technologies: ['Flutter', 'Dart', 'Material Design'],
        githubUrl: 'https://github.com/yourusername/portfolio',
      ),
      Project(
        title: 'Task Manager App',
        description: 'A beautiful task management application',
        imageUrl: 'assets/taskmanager.png',
        technologies: ['Flutter', 'Firebase', 'State Management'],
        githubUrl: 'https://github.com/yourusername/taskmanager',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return ProjectCard(project: projects[index]);
        },
      ),
    );
  }
}
