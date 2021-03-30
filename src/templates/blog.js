import { graphql } from 'gatsby'
import PropTypes from 'prop-types'
import React from 'react'
import { BlogLayout, Pagination, PostCard } from '../components/common'
import { MetaData } from '../components/common/meta'

/**
 * Main blog page (list of posts)
 *
 * Loads all posts from Ghost and uses pagination to navigate through them.
 * The number of posts that should appear per page can be setup
 * in /utils/siteConfig.js under `postsPerPage`.
 *
 */
const Blog = ({ data, location, pageContext }) => {
  const posts = data.allGhostPost.edges

  return (
    <>
      <MetaData location={location} />
      <BlogLayout isHome={false}>
        <div className="container">
          <section className="post-feed">
            {posts.map(({ node }) => (
              // The tag below includes the markup for each post - components/common/PostCard.js
              <PostCard key={node.id} post={node} />
            ))}
          </section>
          <Pagination pageContext={pageContext} />
        </div>
      </BlogLayout>
    </>
  )
}

Blog.propTypes = {
  data: PropTypes.shape({
    allGhostPost: PropTypes.object.isRequired,
  }).isRequired,
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  pageContext: PropTypes.object,
}

export default Blog

// This page query loads all posts sorted descending by published date
// The `limit` and `skip` values are used for pagination
export const pageQuery = graphql`
  query GhostPostQuery($limit: Int!, $skip: Int!) {
    allGhostPost(
      sort: { order: DESC, fields: [published_at] }
      limit: $limit
      skip: $skip
    ) {
      edges {
        node {
          ...GhostPostFields
        }
      }
    }
  }
`
