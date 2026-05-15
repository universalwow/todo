# UNI-7

## Overview

This repository contains the implementation for Linear ticket `UNI-7` (新增todo列表).

## Development

The Phoenix application lives in `uni7/`.

```bash
cd uni7
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
```

Then visit `http://localhost:4000/todos`.

