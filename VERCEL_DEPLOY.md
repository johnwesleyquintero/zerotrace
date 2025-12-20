# Vercel Deployment Configuration

Since the ZeroTrace landing page is located in the `web/` subdirectory, follow these steps to deploy to Vercel:

## 1. Connect your Repository
Connect your GitHub repository to Vercel as you normally would.

## 2. Configure Project Settings
During the import process, or in the Project Settings after importing:

- **Root Directory**: Set this to `web`.
- **Build Command**: `npm run build` (Default)
- **Output Directory**: `.next` (Default)
- **Install Command**: `npm install` (Default)

## 3. Alternative (vercel.json)
If you prefer to keep the configuration in the codebase, you can use a `vercel.json` in the root of the repository (not inside `web/`):

```json
{
  "buildCommand": "cd web && npm run build",
  "outputDirectory": "web/.next",
  "installCommand": "cd web && npm install"
}
```

*Note: The Root Directory setting in the Vercel UI is generally the cleanest approach for monorepos or sub-directory projects.*
