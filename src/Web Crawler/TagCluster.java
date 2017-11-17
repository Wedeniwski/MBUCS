import java.util.*;

public class TagCluster {
  String name;
  int factor;
  Set<String> tags;
  List<TagCluster> nextLevel;
  boolean validated;

  public TagCluster(String n, int f, Set<String>tgs) {
    this(f, tgs);
    name = n;
  }
  
  public TagCluster(int f, Set<String>tgs) {
    name = null;
    factor = f;
    tags = tgs;
    nextLevel = new ArrayList<TagCluster>(3);
    validated = false;
  }

  public void add(Set<String> tgs) {
    tags.addAll(tgs);
    validated = false;
  }

  public void addLevel(TagCluster cluster) {
    nextLevel.add(cluster);
    validated = false;
  }

  public String toString() {
    StringBuilder sb = new StringBuilder(1000);
    if (name != null) {
      sb.append(name);
      sb.append(" (");
      sb.append(factor);
      sb.append("):");
    } else {
      sb.append(factor);
      sb.append(':');
    }
    boolean first = true;
    for (String t : tags) {
      if (!first) sb.append(',');
      sb.append(t);
      first = false;
    }
    for (TagCluster t : nextLevel) {
      sb.append("\n+");
      sb.append(t.toString());
    }
    return sb.toString();
  }

  public String toCompactString(Tags tgs) {
    StringBuilder sb = new StringBuilder(2000);
    sb.append('[');
    if (name != null) {
      sb.append('\"');
      sb.append(name);
      sb.append('\"');
    }
    sb.append(factor);
    sb.append('[');
    Set<Integer> tgIds = tgs.convertTagsToIds(tags);
    boolean first = true;
    for (Integer i : tgIds) {
      if (!first) sb.append(',');
      sb.append(i);
      first = false;
    }
    sb.append(']');
    for (TagCluster t : nextLevel) {
      sb.append(t.toCompactString(tgs));
    }
    sb.append(']');
    return sb.toString();
  }
}
