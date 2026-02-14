# Dataview Cards Demo

If the Dataview plugin is enabled, the queries below should render using built-in card styling from the theme.

## Dataview Table Cards

```dataview
TABLE file.folder AS Folder, file.mtime AS Updated
FROM ""
WHERE file.name != this.file.name
SORT file.name ASC
LIMIT 12
```

## Dataview List Cards

```dataview
LIST
FROM "Projects" OR "Talks" OR "Blog" OR "Code-Documentation"
SORT file.name ASC
```
