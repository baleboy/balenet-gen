//
//  Template.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 8.1.2025.
//

import Foundation

struct Template {
    let title: String
    
    var header: String {
        return """
        <!DOCTYPE html>
        <html>
          <head>
            <title>\(title)</title>
            <meta charset="UTF-8">
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Inconsolata&display=swap" rel="stylesheet">
            <script src="https://kit.fontawesome.com/425a6b9b56.js" crossorigin="anonymous"></script>
            <link rel="stylesheet" type="text/css" href="/style.css">
            <link rel="icon" type="image/x-icon" href="/favicon.ico">
          </head>
          <body>
            <header>
                <div class="title-wrapper">
                    <h1><a href="/">\(title)</a></h1>
                </div>
                <nav>
                  <ul>
                    <li><a href="/work/">Work</a></li>
                    <li><a href="/about/">About</a></li>
                  </ul>
                </nav>
              </header>
            <main>
        """
    }
    
    var footer: String {
        return """
            </main>
            <footer>
                <p>Copyright &copy Bale 2023</p>
              </footer>      
          </body>
        </html>
        """
    }
    
    func getPage(withContent content: String) -> String {
        return header + content + footer
    }
    
    func getHomePage(intro: String, postlist: [Post]) -> String {
        
        var homePageContent = """
            <p>\(intro)</p>
            <h2>Posts</h2>
            <ul class="post-list">
        """
        
        homePageContent += postlist.map { post in
            """
            <li>
                <h3>
                    <a href="\(post.path)">\(post.title)</a></h3>
                    <time>\(dateToString(post.date))</time>    
                </li>
            """
        }.joined()

        homePageContent += "</ul>"
        return getPage(withContent: homePageContent)
    }
    
    func getProjectsPage(intro: String, projectlist: [Project]) -> String {
        
        var pageContent = """
            <h2>Work</h2>
            <p>\(intro)</p>
            <div class="card-container work">
        """
        
        pageContent += projectlist.map { project in
            """
                <a href="\(project.path)">
                    <div class="card">
                        <img src="\(project.image)" alt="\(project.title)">                        
                        <h3>\(project.title)</h3>
                    </div>
                </a>
            """
        }.joined()

        pageContent += "</div>"
        return getPage(withContent: pageContent)
    }

    
    func getPost(post: Post) -> String {
        let body =  """
                <article>
                    <h2>\(post.title)</h2>
                    <time>\(dateToString(post.date))</time>
                    <p></p>
                    \(post.html)
                </article>
            """
        return getPage(withContent: body)
    }
    
    func getProject(project: Project) -> String {
        let body =  """
                <article>
                    <h2>\(project.title)</h2>
                    <p></p>
                    \(project.html)
                </article>
            """
        return getPage(withContent: body)
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}
